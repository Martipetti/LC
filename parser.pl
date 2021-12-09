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
    mailto([C1, C2, C3, C4, C5, C6]), !,
    duepunti(SchemeRest, SchemeRestAgg), 
    compress([C1, C2, C3, C4, C5, C6], Scheme),
    stringId(SchemeRestAgg, UserinfoRest, UserinfoProv),
    compress(UserinfoProv, Userinfo),
    at(UserinfoRest, UserinfoRestAgg),
    hostId(UserinfoRestAgg, [], HostProv),
    compress(HostProv, Host).

%metodi per caso 1 (con authority)
gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :-
    %metodo gestione scheme
    scheme(Stringa, Scheme, SchemeRest), 
    %metodo gestione parte authorithy 
    authorithy(SchemeRest, Userinfo, Host, Port, PortRest),
    %metodo gestione di path, query e fragment
    coda(PortRest, Path, Query, Fragment).
    
%metodi per caso 2 (senza authority)
gestion(Stringa, Scheme, [], [], [], Path, Query, Fragment) :-
    %metodo per gestione scheme
    scheme(Stringa, Scheme, SchemeRest), 
    %metodo per gestione di path, query e fragment
    coda(SchemeRest, Path, Query, Fragment).    


%metodo mailto
mailto([C1, C2, C3, C4, C5, C6]) :-
    C1 == 'm', C2 == 'a', C3 == 'i',
    C4 == 'l', C5 == 't', C6 == 'o'.

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
    compress(UserinfoProv, Userinfo), %write(Userinfo), nl,
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
    !, %%%
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
    is_digit(N10), is_digit(N11), is_digit(N12), !,
    ip([N1, N2, N3, P1, N4, N5, N6, P2, N7, N8, N9, P3, N10, N11, N12]).

%identificazione host
hostId([C|Cs], Cs1, [C|Is]) :- 
    C\='/', C\='?', C\='#', C\='@', C\=':', C\='.',
    !, 
    stringId(Cs, Cs1, Is).
hostId(Cs, Cs, []).

%controllo su ip
ip([N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12]) :-
    X = (N1*100 + N2*10 + N3), 
    Y is (N4*100 + N5*10 + N6), 
    Z is (N7*100 + N8*10 + N9),
    T is (N10*100 + N11*10 + N12),
    digit(X), digit(Y), digit(Z), digit(T).
%numeriIP
digit(C):-
    C >=0,
    C=<255.

%identificazione path
pathId([C|Cs], Cs1, [C|Is]) :-
    C\='?', C\='#', C\='@', C\=':',
    !, 
    stringId(Cs, Cs1, Is).
pathId(Cs, Cs, []).

%identificazione port
portId([C|Cs], Cs1, [C|Is]) :-
    digit(C),
    !,
    portId(Cs, Cs1, Is).
    portId(Cs, Cs, []).

% controllo indirizzo IP
indirizzoIP([C1, C2, C3, C4, C5, C6, C7|Cs], Cs, [C1,C2,C3,C4,C5,C6,C7]) :- 
    digit2(C1), C2=='.', digit2(C3), C4=='.', digit2(C5), C6=='.', digit2(C7).

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
