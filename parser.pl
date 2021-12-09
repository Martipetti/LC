%to do list:


uri_parse(URIString, URI) :-
    string_chars(URIString, Stringa), %write(Stringa), nl,
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), 
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).
    %URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).

%gestione generale dell'uri
gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :-
    %metodo per gestione scheme
    scheme(Stringa, Scheme, SchemeRest), %write(Scheme), nl, write(SchemeRest), nl,
    %metodo per gestione parte authorithy 
    authorithy(SchemeRest, Userinfo, Host, Port, PortRest),
    %metodo per gestione di path, query e fragment
    coda(PortRest, Path, Query, Fragment).

%gestione dello scheme con controllo ':'
scheme(URIString, Scheme, StringAgg) :-
    stringId(URIString, Stringa, SchemeProv), %write(Stringa), nl, write(SchemeProv), nl,
    duepunti(Stringa, StringAgg), 
    compress(SchemeProv, Scheme).
duepunti([C | Lista], Lista) :-
    C == ':'.

%gestione authorithy, caso userinfo e port
authorithy([S1, S2 | SchemeRest], Userinfo, Host, Port, PortRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C1 | UserinfoRest], UserinfoProv), 
    compress(UserinfoProv, Userinfo), %write(Userinfo), nl,
    C1 == '@',
    stringId(UserinfoRest, [C2 | HostRest], HostProv),
    compress(HostProv, Host),
    C2 == ':',
    !,
    stringId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).
%caso userinfo
authorithy([S1, S2 | SchemeRest], Userinfo, Host, [], HostRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C | UserinfoRest], UserinfoProv),
    compress(UserinfoProv, Userinfo),
    C == '@',
    !,
    stringId(UserinfoRest, HostRest, HostProv),
    compress(HostProv, Host).
%caso port
authorithy([S1, S2 | SchemeRest], [], Host, Port, PortRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, [C | HostRest], HostProv), 
    compress(HostProv, Host),
    C == ':',
    !,
    stringId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).
%caso senza port ne useinfo
authorithy([S1, S2 | SchemeRest], [], Host, [], HostRest) :- 
    S1 == '/', S2 == '/',
    stringId(SchemeRest, HostRest, HostProv), 
    compress(HostProv, Host).

%gestione metodo coda
coda([C | PortRest], Path, Query, Fragment) :-
    C == '/',
    pathSlash(PortRest, PathRest, Path),
    queryQuestion(PathRest, QueryRest, Query),
    fragmentHastag(QueryRest, [], Fragment).
coda([], [], [], []).
%metodi usati in coda
pathSlash([C | PortRest], PathRest, Path) :-
    C == '/', !,
    pathId(PortRest, PathRest, PathProv),
    compress(PathProv, Path).
pathSlash(PortRest, PortRest, []).

queryQuestion([C | PathRest], QueryRest, Query) :-
    C == '?', !,
    queryId(PathRest, QueryRest, QueryProv),
    compress(QueryProv, Query).
queryQuestion(PathRest, PathRest, []).

fragmentHastag([C | QueryRest], FragmentRest, Fragment) :-
    C == '#', !,
    fragmentId(QueryRest, FragmentRest, FragmentProv),
    compress(FragmentProv, Fragment).
fragmentHastag(QueryRest, QueryRest, []).


%identificazione stringa dello scheme
stringId([C|Cs], Cs1, [C|Is]) :- 
    C\='/', C\='?', C\='#', C\='@', C\=':',!, 
    stringId(Cs, Cs1, Is).
stringId(Cs, Cs, []).

%identificazione path
pathId([C|Cs], Cs1, [C|Is]) :-
    C\='?', C\='#', C\='@', C\=':',!, 
    stringId(Cs, Cs1, Is).
pathId(Cs, Cs, []).

%identificazione query
queryId([C|Cs], Cs1, [C|Is]) :-
    C\='#', !, 
    stringId(Cs, Cs1, Is).
queryId(Cs, Cs, []).

%identificazione fragment
fragmentId([C|Cs], Cs1, [C|Is]) :-
    !, %non sicuro di questo cut
    stringId(Cs, Cs1, Is).
fragmentId(Cs, Cs, []).

%metodo per unire la lista in una stringa
compress([], []) :- !.
compress(List, Result) :- 
    string_chars(List1, List), 
    atom_string(Result, List1).
