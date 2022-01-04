uri_parse(URIString, URI) :-
    %passaggio dalla stringa a una lista di caratteri
    string_chars(URIString, Stringa), 
    %metodo che in base alla lista passa a stati di metodi diversi
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), !,
    %output
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).

%parser usato da uri_display
uri_parse2(URIString, URI) :-
    %passaggio dalla stringa a una lista di caratteri
    string_chars(URIString, Stringa), 
    %metodo che in base alla lista passa a stati di metodi diversi
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), !,
    %output
    URI = [Scheme, Userinfo, Host, Port, Path, Query, Fragment].

%stampa su terminale
uri_display(URIString) :-
    %lista(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query', 'Fragment']),
    uri_parse2(URIString, URI), 
    stampa(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query', 'Fragment'], URI).
%gestione write
stampa([E1 | Lista], [E2 | URI]) :-
    write(E1), write(': '), write(E2), nl, 
    stampa(Lista, URI).
stampa([], []).

%stampa su stream
uri_display(URIString, File) :-
    %lista(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query', 'Fragment']),
    uri_parse2(URIString, URI), 
    stampa2(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query', 'Fragment'], URI, File).
%apertura e chiusura stream
stampa2(Lista, URI, F) :-
    open(F, write, File),
    stampa3(Lista, URI, File), 
    close(File).
%gestione write
stampa3([E1 | Lista], [E2 | URI], F) :-
    write(F, E1), 
    write(F, ': '), 
    write(F, E2), 
    nl(F),
    stampa3(Lista, URI, F).
stampa3([], [], _F).


%metodo di gestione generale dell'uri 
%metodi per mailto 
gestion([C1, C2, C3, C4, C5, C6 | SchemeRest], Scheme, Userinfo, Host, [], '80', [], []) :-
    %controllo sintassi 'mailto'
    mailto([C1, C2, C3, C4, C5, C6], Scheme), !,
    %metodo gestione userinfo e host
    codaM(SchemeRest, Userinfo, Host).

%metodi per news
gestion([C1, C2, C3, C4| SchemeRest], Scheme, [] , Host, '80', [], [], []) :-
    %controllo sintassi 'news'
    news([C1, C2, C3, C4], Scheme), !,
    %metodo gestione host
    codaN(SchemeRest, Host).

%metodi per tel 
gestion([C1, C2, C3| SchemeRest], Scheme, Userinfo, [], '80', [], [], []) :-
    %controllo sintassi 'tel'
    tel([C1, C2, C3], Scheme), !,
    %metodo gestione userinfo 
    codaT(SchemeRest, Userinfo).

%metodi per fax
gestion([C1, C2, C3| SchemeRest], Scheme, Userinfo, [], '80', [], [], []) :-
    %controllo sintassi 'tel'
    fax([C1, C2, C3], Scheme), !,
    %metodo gestione userinfo 
    codaT(SchemeRest, Userinfo).

%metodi per zos
gestion([C1, C2, C3| SchemeRest], Scheme, Userinfo, Host, Port, Path, Query, Fragment) :- 
    %controllo sintassi 'zos'
    zos([C1, C2, C3], Scheme), !,
    %metodo gestione path
    codaZ(SchemeRest, Userinfo, Host, Port, Path, Query, Fragment).

%metodi per caso 1 (con authority)
gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :-
    %metodo gestione scheme
    scheme(Stringa, Scheme, SchemeRest), 
    %metodo gestione parte authorithy 
    authorithy(SchemeRest, Userinfo, Host, Port, PortRest), !, 
    %metodo gestione di path, query e fragment
    coda(PortRest, Path, Query, Fragment).
    
%metodi per caso 2 (senza authority)
gestion(Stringa, Scheme, [], [], '80', Path, Query, Fragment) :-
    %metodo per gestione scheme
    scheme(Stringa, Scheme, SchemeRest), !,
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

%metodo fax
fax([C1, C2, C3], Scheme) :-
    C1 == 'f', C2 == 'a', C3 == 'x',
    compress([C1, C2, C3], Scheme).

%coda scheme tel e fax
codaT(SchemeRest, Userinfo) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    stringId(SchemeRestAgg, [], UserinfoProv),
    compress(UserinfoProv, Userinfo).

%metodo zos
zos([C1, C2, C3], Scheme) :-
    C1 == 'z', C2 == 'o', C3 == 's',
    compress([C1, C2, C3], Scheme).

%coda scheme zos con authority
codaZ(SchemeRest, Userinfo, Host, Port, Path, Query, Fragment) :-
     duepunti(SchemeRest, SchemeRestAgg), 
     authorithy(SchemeRestAgg, Userinfo, Host, Port, PortRest), 
     pathSlash2(PortRest, PathRest, Path), 
     coda2(PathRest, Query, Fragment).

%coda scheme zos senza authority
codaZ(SchemeRest, [], [], '80', Path, Query, Fragment) :-
     duepunti(SchemeRest, SchemeRestAgg), 
     pathSlash2(SchemeRestAgg, PathRest, Path), 
     coda2(PathRest, Query, Fragment).

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
authorithy([S1, S2 | SchemeRest], Userinfo, Host, '80', HostRest) :- 
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
    hostId(SchemeRest, [C | HostRest], HostProv), 
    compress(HostProv, Host),
    C == ':',
    !,
    portId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).
%caso senza port ne useinfo
authorithy([S1, S2 | SchemeRest], [], Host, '80', HostRest) :- 
    S1 == '/', S2 == '/', !,
    hostId(SchemeRest, HostRest, HostProv), 
    compress(HostProv, Host).

%gestione metodo coda:
%con e senza authority 
coda([C | PortRest], Path, Query, Fragment) :-
    C == '/', !,
    pathSlash(PortRest, PathRest, Path),
    queryQuestion(PathRest, QueryRest, Query),
    fragmentHastag(QueryRest, [], Fragment).
coda([], [], [], []).

%coda zos
coda2(PathRest, Query, Fragment) :-
    queryQuestion(PathRest, QueryRest, Query), !,
    fragmentHastag(QueryRest, [], Fragment).
coda2([], [], []).


%metodi usati in coda
pathSlash(PortRest, PathRest, Path) :-
    pathId(PortRest, PathRest, PathProv), !,
    compress(PathProv, Path).
pathSlash(PortRest, PortRest, []).

%metodi usati in codaZ
pathSlash2(PortRest, PathRest, Path) :-
    pathZos(PortRest, PathRest, PathProv), !,
    compress(PathProv, Path).


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

%pathZos con id44 e id8
pathZos([C, C1| Cs], Cs2, [C1 | Is]):-
    C=='/',
    is_alpha(C1),
    !,
    Cont=0,
    pathZos2(Cs, Cs1, Is1, Cont), 
    \+(last(Is1, '.')),
    pathZos3(Cs1, Cs2, Is2, Cont), 
    append(Is1, Is2, Is).

pathZos2([C | Cs], Cs1, [C | Is], Cont):-
     C=='.',
     !,
     somma(Cont, 1, R), 
     R =< 43,
     pathZos2(Cs, Cs1, Is, R).
pathZos2([C | Cs], Cs1, [C | Is], Cont):-
    is_alnum(C),
    !,
    somma(Cont, 1, R), 
    R =< 43,
    pathZos2(Cs, Cs1, Is, R).
pathZos2(Cs, Cs, [], _C).
%metodi in pathZos id44 e id8 
pathZos3([C | Cs], Cs1, Is, Cont1):-
    C == '(',
    !,
    Cont1=0,
    pathZos4(Cs, [C2 | Cs1], Is1, Cont1), 
    append([C], Is1, IsA), 
    C2 == ')',
    append(IsA, [C2], Is).
pathZos3(Cs, Cs, [], _C).
pathZos4([C, C1 | Cs], Cs1, [C, C1 | Is], Cont1):-
    is_alpha(C),
    is_alnum(C1), 
    !,
    somma(Cont1, 1, R), 
    R =< 7,  
    pathZos4(Cs, Cs1, Is, R). 
pathZos4(Cs, Cs, [], _C).
%metodo somma usato in pathZos
somma(X, Y, Z):-
    Z is (X + Y).
    
%identificazione stringa dello scheme
stringId([C|Cs], Cs1, [C|Is]) :- 
    C\='/', C\='?', C\='#', C\='@', C\=':',
    !, 
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
portId([C |Cs], Cs1, [C | Is]) :-
    is_digit(C),
    !, 
    portId(Cs, Cs1, Is).
portId(Cs, Cs, []).

%identificazione query
queryId([C|Cs], Cs1, [C|Is]) :-
    C\='#', 
    !, 
    queryId(Cs, Cs1, Is).
queryId(Cs, Cs, []).

%identificazione fragment
fragmentId([C|Cs], Cs1, [C|Is]) :-
    %!, 
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
    
