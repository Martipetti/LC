uri_parse(URIString, URI) :-
    %passaggio dalla stringa a una lista di caratteri
    string_chars(URIString, Stringa), 
    %metodo che in base alla lista passa a stati di metodi diversi
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), 
    %output
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).


%metodo di gestione generale dell'uri 
%metodi per mailto 
gestion([C1, C2, C3, C4, C5, C6 | SchemeRest], Scheme, Userinfo, Host, [], [], [], []) :-
    %controllo sintassi 'mailto'
    mailto([C1, C2, C3, C4, C5, C6], Scheme), !,
    %metodo gestione userinfo e host
    codaM(SchemeRest, Userinfo, Host).

%metodi per news
gestion([C1, C2, C3, C4| SchemeRest], Scheme, [] , Host, [], [], [], []) :-
    %controllo sintassi 'news'
    news([C1, C2, C3, C4], Scheme), !,
    %metodo gestione host
    codaN(SchemeRest, Host).

%metodi per tel 
gestion([C1, C2, C3| SchemeRest], Scheme, Userinfo, [], [], [], [], []) :-
    %controllo sintassi 'tel'
    tel([C1, C2, C3], Scheme), !,
    %metodo gestione userinfo 
    codaT(SchemeRest, Userinfo).

%metodi per fax
gestion([C1, C2, C3| SchemeRest], Scheme, Userinfo, [], [], [], [], []) :-
    %controllo sintassi 'fax'
    fax([C1, C2, C3], Scheme), !,
    %metodo gestione userinfo 
    codaT(SchemeRest, Userinfo).

%metodi per caso 1 (con authority)
gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :-
    %metodo gestione scheme
    scheme(Stringa, Scheme, SchemeRest), %!,
    %metodo gestione parte authorithy 
    authorithy(SchemeRest, Userinfo, Host, Port, PortRest),
    %metodo gestione di path, query e fragment
    coda(PortRest, Path, Query, Fragment).
    
%metodi per caso 2 (senza authority)
gestion(Stringa, Scheme, [], [], [], Path, Query, Fragment) :-
    %metodo per gestione scheme
    scheme(Stringa, Scheme, SchemeRest), %!,
    %metodo per gestione di path, query e fragment
    coda(SchemeRest, Path, Query, Fragment).    


%metodo mailto
mailto([C1, C2, C3, C4, C5, C6], Scheme) :-
    C1 == 'm', C2 == 'a', C3 == 'i',
    C4 == 'l', C5 == 't', C6 == 'o',
    compress([C1, C2, C3, C4, C5, C6], Scheme).

%coda scheme mailto
codaM(SchemeRest, Userinfo, Host) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    stringId(SchemeRestAgg, UserinfoRest, UserinfoProv),
    compress(UserinfoProv, Userinfo),
    hostMailto(UserinfoRest, Host).

%gestione host scheme mailto
hostMailto(UserinfoRest, Host) :-
    at(UserinfoRest, UserinfoRestAgg),!,  
    hostId(UserinfoRestAgg, [], HostProv), 
    compress(HostProv, Host).
hostMailto([], []).

%metodo news
news([C1, C2, C3, C4], Scheme) :-
    C1 == 'n', C2 == 'e', C3 == 'w',
    C4 == 's',
    compress([C1, C2, C3, C4], Scheme).

%coda scheme news
codaN(SchemeRest, Host) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    hostId(SchemeRestAgg, [], HostProv),
    compress(HostProv, Host).

%metodo tel
tel([C1, C2, C3], Scheme) :-
    C1 == 't', C2 == 'e', C3 == 'l',
    compress([C1, C2, C3], Scheme).

%coda scheme tel e fax
codaT(SchemeRest, Userinfo) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    stringId(SchemeRestAgg, [], UserinfoProv),
    compress(UserinfoProv, Userinfo).

%metodo fax
fax([C1, C2, C3], Scheme) :-
    C1 == 'f', C2 == 'a', C3 == 'x',
    compress([C1, C2, C3], Scheme).


%gestione dello scheme con controllo ':'
scheme(URIString, Scheme, StringAgg) :-
    stringId(URIString, Stringa, SchemeProv), 
    duepunti(Stringa, StringAgg), 
    compress(SchemeProv, Scheme).


%gestione authorithy:
%caso userinfo e port
authorithy([S1, S2 | SchemeRest], Userinfo, Host, Port, PortRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C1 | UserinfoRest], UserinfoProv), 
    compress(UserinfoProv, Userinfo), 
    C1 == '@',
    hostId(UserinfoRest, [C2 | HostRest], HostProv),
    compress(HostProv, Host),
    C2 == ':',
    !,
    portId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).
%caso userinfo
authorithy([S1, S2 | SchemeRest], Userinfo, Host, [], HostRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C | UserinfoRest], UserinfoProv),
    compress(UserinfoProv, Userinfo),
    C == '@',
    !,
    hostId(UserinfoRest, HostRest, HostProv),
    compress(HostProv, Host).
%caso port
authorithy([S1, S2 | SchemeRest], [], Host, Port, PortRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C | HostRest], HostProv), 
    compress(HostProv, Host),
    C == ':',
    !,
    portId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).
%caso senza port ne useinfo
authorithy([S1, S2 | SchemeRest], [], Host, [], HostRest) :- 
    S1 == '/', S2 == '/',
    hostId(SchemeRest, HostRest, HostProv), 
    compress(HostProv, Host).

%gestione metodo coda:
%con authority 
coda([C | PortRest], Path, Query, Fragment) :-
    C == '/',
    pathSlash(PortRest, PathRest, Path),
    queryQuestion(PathRest, QueryRest, Query),
    fragmentHastag(QueryRest, [], Fragment).
coda([], [], [], []).
%gestione metodo coda senza authority
coda(PortRest, Path, Query, Fragment) :-
    pathSlash(PortRest, PathRest, Path),
    queryQuestion(PathRest, QueryRest, Query),
    fragmentHastag(QueryRest, [], Fragment).
coda([], [], [], []).

%metodi usati in coda
pathSlash(PortRest, PathRest, Path) :-
    !, 
    pathId(PortRest, PathRest, PathProv),
    compress(PathProv, Path).
pathSlash(PortRest, PortRest, []).

queryQuestion([C | PathRest], QueryRest, Query) :-
    C == '?',
    !,
    queryId(PathRest, QueryRest, QueryProv),
    compress(QueryProv, Query).
queryQuestion(PathRest, PathRest, []).

fragmentHastag([C | QueryRest], FragmentRest, Fragment) :-
    C == '#', 
    !,
    fragmentId(QueryRest, FragmentRest, FragmentProv),
    compress(FragmentProv, Fragment).
fragmentHastag(QueryRest, QueryRest, []).



%identificazione stringa dello scheme
stringId([C|Cs], Cs1, [C|Is]) :- 
    C\='/', C\='?', C\='#', C\='@', C\=':',!, 
    stringId(Cs, Cs1, Is).
stringId(Cs, Cs, []).

%versione host per ip
hostId([N1, N2, N3, P1, N4, N5, N6, P2, N7, N8, N9, P3, N10, N11, N12 | Cs], Cs, 
    [N1, N2, N3, P1, N4, N5, N6, P2, N7, N8, N9, P3, N10, N11, N12]) :-
    is_digit(N1), is_digit(N2), is_digit(N3),
    P1 == '.',
    is_digit(N4), is_digit(N5), is_digit(N6),
    P2 == '.',
    is_digit(N7), is_digit(N8), is_digit(N9),
    P3 == '.',
    is_digit(N10), is_digit(N11), is_digit(N12), 
    !,
    ip([N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12]).

%identificazione host
hostId([C|Cs], Cs1, [C|Is]) :- 
    C\='/', C\='?', C\='#', C\='@', C\=':', C\='.',
    !, 
    stringId(Cs, Cs1, Is).
hostId(Cs, Cs, []).

%controllo su ip
ip([N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12]) :-
    fun(N1, N2, N3), 
    fun(N4, N5, N6),
    fun(N7, N8, N9),
    fun(N10, N11, N12).
%funzione
fun(C1, C2, C3) :-
    atom_number(C1, N1),
    atom_number(C2, N2),
    atom_number(C3, N3),
    O = (N1*100 + N2*10 + N3), 
    digit(O).

%numeriIP
digit(C):-
    C >=0,
    C=<255.

%identificazione path
pathId([C|Cs], Cs1, [C|Is]) :-
    C\='?', C\='#', C\='@', C\=':', C\='/',
    !, 
    pathId(Cs, Cs1, Is).
pathId(Cs, Cs, []).

%identificazione port
portId([C, C1|Cs], Cs, [C C1]) :-
    C=='8', C1=='0',
    !.
 
%identificazione query
queryId([C|Cs], Cs1, [C|Is]) :-
    C\='#', 
    !, 
    queryId(Cs, Cs1, Is).
queryId(Cs, Cs, []).

%identificazione fragment
fragmentId([C|Cs], Cs1, [C|Is]) :-
    !, 
    fragmentId(Cs, Cs1, Is).
fragmentId(Cs, Cs, []).

%metodi per simboli singoli
duepunti([C | Lista], Lista) :-
    C == ':'.

at([C | Lista], Lista) :-
    C == '@'.

%metodo per unire la lista in una stringa
compress([], []) :- !.
compress(List, Result) :- 
    string_chars(List1, List), 
    atom_string(Result, List1).
