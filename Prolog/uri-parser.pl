%%%-*- Mode: Prolog -*- 

/* Componenti del gruppo:
   Merlo Daniela 866380
   Pettinari Martino 866496
*/

/*metodo principale a cui viene passata la stringa in input e ritorna
  l'URI suddiviso nelle sue componenti
  che viene trasformata in una lista e successivamente gestita 
  dal metodo gestion 
*/
uri_parse(URIString, URI) :-
    %%%passaggio dalla stringa a una lista di caratteri
    string_chars(URIString, Stringa), 
    %%%metodo che in base alla lista passa a stati di metodi diversi
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), !,
    %%%output
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).

%%%parser usato da uri_display
uri_parse2(URIString, URI) :-
    %%%passaggio dalla stringa a una lista di caratteri
    string_chars(URIString, Stringa), 
    %%%metodo che in base alla lista passa a stati di metodi diversi
    gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment), !,
    %%%output
    URI = [Scheme, Userinfo, Host, Port, Path, Query, Fragment].

/* Primo metodo uri-display con stampa sul terminale
   ha come unico argomento la stringa in input
*/
uri_display(URIString) :-
    uri_parse2(URIString, URI), 
    stampa(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query',
	    'Fragment'], URI).
%%%gestione write
stampa([E1 | Lista], [E2 | URI]) :-
    write(E1),
    write(':'),
    write(E2),
    nl, 
    stampa(Lista, URI).
stampa([], []).

/* Secondo metodo uri-display a cui viene passata la stringa e un file 
   in cui stampare l'output 
*/
uri_display(URIString, File) :-
    uri_parse2(URIString, URI), 
    stampa2(['Scheme', 'Userinfo', 'Host', 'Port', 'Path', 'Query',
	     'Fragment'], URI, File).

%%%apertura e chiusura dello stream
stampa2(Lista, URI, F) :-
    open(F, write, File),
    stampa3(Lista, URI, File), 
    close(File).

%%%gestione write per metodo uri-display con stream 
stampa3([E1 | Lista], [E2 | URI], F) :-
    write(F, E1), 
    write(F, ': '), 
    write(F, E2), 
    nl(F),
    stampa3(Lista, URI, F).
stampa3([], [], _F).


/* Succesivamente si trovano delle serie di metodi per la gestione
   delle sintassi speciali: mailto, news, tel, fax e zos
*/

%%%metodo gestione sintassi 'mailto'
gestion([C1, C2, C3, C4, C5, C6 | SchemeRest], Scheme, Userinfo, Host, [],
	'80', [], []) :-
    %%%controllo sintassi 'mailto'
    mailto([C1, C2, C3, C4, C5, C6], Scheme), !,
    %%%metodo gestione userinfo e host per 'mailto'
    codaM(SchemeRest, Userinfo, Host).

%%%metod0 gestione sintatti news
gestion([C1, C2, C3, C4 | SchemeRest], Scheme, [] , Host, '80', [], [], []) :-
    %%%controllo sintassi 'news'
    news([C1, C2, C3, C4], Scheme), !,
    %%%metodo gestione host per news 
    codaN(SchemeRest, Host).

%%%metodo gestione sintassi tel 
gestion([C1, C2, C3 | SchemeRest], Scheme, Userinfo, [], '80', [], [], []) :-
    %%%controllo sintassi 'tel'
    tel([C1, C2, C3], Scheme), !,
    %%%metodo gestione userinfo per tel
    codaT(SchemeRest, Userinfo).

%%%metodo gestione sintassi fax
gestion([C1, C2, C3 | SchemeRest], Scheme, Userinfo, [], '80', [], [], []) :-
    %%%controllo sintassi 'tel'
    fax([C1, C2, C3], Scheme), !,
    %%%metodo gestione userinfo per fax
    codaT(SchemeRest, Userinfo).

%%%metodo gestione sintassi zos
gestion([C1, C2, C3 | SchemeRest], Scheme, Userinfo, Host, Port, Path, Query,
	Fragment) :- 
    %%%controllo sintassi 'zos'
    zos([C1, C2, C3], Scheme), !,
    %%%metodo gestione path per zos
    codaZ(SchemeRest, Userinfo, Host, Port, Path, Query, Fragment).

/* Metodo principale per la gestione dell'URI 
   Il metodo gestisce il caso in cui sia presente l'authority 
*/
gestion(Stringa, Scheme, Userinfo, Host, Port, Path, Query, Fragment) :-
    %%%metodo gestione scheme
    scheme(Stringa, Scheme, SchemeRest), 
    %%%metodo gestione parte authorithy 
    authorithy(SchemeRest, Userinfo, Host, Port, PortRest), !, 
    %%%metodo gestione di path, query e fragment
    coda(PortRest, Path, Query, Fragment).

/* Metodo per la gestione dell'URI 
   Analizza il caso in cui l'authority non sia presente
   Abbiamo mantenuto la porta di default a 80
*/
gestion(Stringa, Scheme, [], [], '80', Path, Query, Fragment) :-
    %%%metodo per gestione scheme
    scheme(Stringa, Scheme, SchemeRest), !,
    %%%metodo per gestione di path, query e fragment
    coda(SchemeRest, Path, Query, Fragment).    


%%%metodo specifico per il controllo della sintassi di mailto 
mailto([C1, C2, C3, C4, C5, C6], Scheme) :-
    C1 == 'm',
    C2 == 'a',
    C3 == 'i',
    C4 == 'l',
    C5 == 't',
    C6 == 'o',
    /*Richiamo al metedo per comprire una lista in una stringa
      mette il risultato nel campo Scheme
    */
    compress([C1, C2, C3, C4, C5, C6], Scheme).

/* Metodo principale per la gestione della sintassi mailto
   vengono richiamati dei sottometodi per il controllo
   della sintasi 
*/
codaM(SchemeRest, Userinfo, Host) :-
    %%% Metedo per controllare la presenza dei ':'
    duepunti(SchemeRest, SchemeRestAgg), 
    %%% Metodo per controllare la presenza di Userinfo
    stringId(SchemeRestAgg, UserinfoRest, UserinfoProv),
    compress(UserinfoProv, Userinfo),
    %%% Metedo per controllare la presenza di host 
    hostMailto(UserinfoRest, Host).

%%% Metodo specifico per la gestione di host in mailto 
hostMailto(UserinfoRest, Host) :-
    %%% Metodo per il controllo della presenza di '@'
    at(UserinfoRest, UserinfoRestAgg), !, 
    %%% Richiamo al metodo principale per il controllo dell'host 
    hostId(UserinfoRestAgg, [], HostProv), 
    compress(HostProv, Host).
%%% caso base del metodo 
hostMailto([], []).

%%% Metodo specifico per il controllo della sintassi news
news([C1, C2, C3, C4], Scheme) :-
    C1 == 'n',
    C2 == 'e',
    C3 == 'w',
    C4 == 's',
    compress([C1, C2, C3, C4], Scheme).

%%% Metodo principale per il controllo della sintassi news
codaN(SchemeRest, Host) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    hostId(SchemeRestAgg, [], HostProv),
    compress(HostProv, Host).

%%% Metodo specifico per il controllo della sintassi tel
tel([C1, C2, C3], Scheme) :-
    C1 == 't',
    C2 == 'e',
    C3 == 'l',
    compress([C1, C2, C3], Scheme).

%%% Metodo specifico per il controllo della sintassi fax
fax([C1, C2, C3], Scheme) :-
    C1 == 'f',
    C2 == 'a',
    C3 == 'x',
    compress([C1, C2, C3], Scheme).

%%% Metodo principale per la sintassi tel e fax 
codaT(SchemeRest, Userinfo) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    stringId(SchemeRestAgg, [], UserinfoProv),
    compress(UserinfoProv, Userinfo).

%%% Metodo specifico per la sintassi zos
zos([C1, C2, C3], Scheme) :-
    C1 == 'z',
    C2 == 'o',
    C3 == 's',
    compress([C1, C2, C3], Scheme).

/* Metodo di gestione per la sintassi zos nel caso in cui
   sia presente la parte di authority, in tutti i casi abbiamo
   considerato il path zos obbligatorio
*/
codaZ(SchemeRest, Userinfo, Host, Port, Path, Query, Fragment) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    authorithy(SchemeRestAgg, Userinfo, Host, Port, PortRest),
    %%% Metodo specifico per il controllo della sintassi di Path zos  
    pathSlash2(PortRest, PathRest, Path),
    %%% Metodo per la gestione di query e fragment 
    coda2(PathRest, Query, Fragment).

/* Metodo di gestione per la sintassi zos nel caso in cui non 
   sia presente la parte di authority 
*/
codaZ(SchemeRest, [], [], '80', Path, Query, Fragment) :-
    duepunti(SchemeRest, SchemeRestAgg), 
    pathSlash2(SchemeRestAgg, PathRest, Path), 
    coda2(PathRest, Query, Fragment).

/* Metodo specifico per la sintassi zos in cui 
   vengono gestiti query e fragment 
*/
coda2(PathRest, Query, Fragment) :-
    queryQuestion(PathRest, QueryRest, Query), !,
    fragmentHastag(QueryRest, [], Fragment).
coda2([], [], []).

/* Metodo principale per la gestione dello scheme 
   in cui viene fatto il controllo per la presenza dei ':'
*/
scheme(URIString, Scheme, StringAgg) :-
    stringId(URIString, Stringa, SchemeProv), 
    duepunti(Stringa, StringAgg), 
    compress(SchemeProv, Scheme).

/* Succesivamente ci sono una serie di metodo che gestiscono
   la parte di authority nei suoi vari casi 
*/
%%% Caso in cui sono presenti Userinfo, Host e Port da input 
authorithy([S1, S2 | SchemeRest], Userinfo, Host, Port, PortRest) :- 
    %%% Controllo delle // che identificano la presenza di authority
    S1 == '/',
    S2 == '/', 
    stringId(SchemeRest, [C1 | UserinfoRest], UserinfoProv), 
    compress(UserinfoProv, Userinfo), 
    %%% Controllo della @ che identifica la presenza di Userinfo 
    C1 == '@', 
    hostId(UserinfoRest, [C2 | HostRest], HostProv),
    compress(HostProv, Host),
    %%% Controllo dei : che identificano la presenza di Port
    C2 == ':',
    !,
    portId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).

%%% Caso in cui sono presenti Userinfo e Host
authorithy([S1, S2 | SchemeRest], Userinfo, Host, '80', HostRest) :- 
    S1 == '/',
    S2 == '/', 
    stringId(SchemeRest, [C | UserinfoRest], UserinfoProv),
    compress(UserinfoProv, Userinfo),
    C == '@',
    !,
    hostId(UserinfoRest, HostRest, HostProv),
    compress(HostProv, Host).

%%% Caso in cui sono presenti Host e Port
authorithy([S1, S2 | SchemeRest], [], Host, Port, PortRest) :- 
    S1 == '/',
    S2 == '/', 
    hostId(SchemeRest, [C | HostRest], HostProv), 
    compress(HostProv, Host),
    C == ':',
    !,
    portId(HostRest, PortRest, PortProv),
    compress(PortProv, Port).

%%% Caso in cui è presente solo Host 
authorithy([S1, S2 | SchemeRest], [], Host, '80', HostRest) :- 
    S1 == '/',
    S2 == '/', !,
    hostId(SchemeRest, HostRest, HostProv), 
    compress(HostProv, Host).

/* Succesivamete sono presenti una serie di metodi
   Per la gestione della parte dopo all'authority
   quindi path, query e fragment
*/

%%% Metodo principale per la gestione di path, query e fragment 
coda([C | PortRest], Path, Query, Fragment) :-
    /* Controllo della presenza '/' carattare
    obbligatorio per la presenza del path 
    */
    C == '/', !,
    %%% Richiamo al metodo gestione path
    pathSlash(PortRest, PathRest, Path),
    %%% Richiamo al metodo gestione query
    queryQuestion(PathRest, QueryRest, Query),
    %%% Richiamo al metedo gestione fragment 
    fragmentHastag(QueryRest, [], Fragment).
%%% Caso base del metodo coda
coda([], [], [], []).


%%% Metodo per la gestione del Path 
pathSlash(PortRest, PathRest, Path) :-
    %%% Richiamo al metedo per il controllo della sintassi di path 
    pathId(PortRest, PathRest, PathProv), !,
    compress(PathProv, Path).
pathSlash(PortRest, PortRest, []).

/* Succesivamente ci sono una serie di metodi
  per la gestione del Path nella sintassi zos
  in particolare pathSlash2 viene richiamto nel metodo
  codaZ
*/
pathSlash2(PortRest, PathRest, Path) :-
    %%% Richiamo al metedo specifico per il controllo
    %%% della sintassi di Path zos
    pathZos(PortRest, PathRest, PathProv), !,
    compress(PathProv, Path).

/*Metodo per il controllo di Path zos
  in particoalre di id44
*/
pathZos([C, C1| Cs], Cs2, [C1 | Is]):-
    C=='/',
    %%% Metodo per controllare che il carattere sia alfabetico
    is_alpha(C1),
    !,
    %%% Inizializzazione del contatore per la lunghezza di id44
    Cont=0,
    %%% Richiamo ai metodi per la sintassi di id44
    pathZos2(Cs, Cs1, Is1, Cont), 
    /* Verifichiamo che l'ultimo carattere di id44
       non sia un '.'
    */
    \+(last(Is1, '.')),
    %%% Richiamo metedo per il controllo di id8
    pathZos3(Cs1, Cs2, Is2, Cont), 
    append(Is1, Is2, Is).

/* Metodo per la sintassi id44 nel caso in cui
   si incontri un '.'
*/
pathZos2([C | Cs], Cs1, [C | Is], Cont):-
    C=='.',
    !,
    somma(Cont, 1, R), 
    %%% Controllo sulla lunghezza di id44
    R =< 43,
    pathZos2(Cs, Cs1, Is, R).

/* Metodo per la sintassi id44 nel caso in cui
   si incontri un carattere alfanumerico
*/
pathZos2([C | Cs], Cs1, [C | Is], Cont):-
    %%% Metodo per controllare che il carattere sia alfanumerico
    is_alnum(C),
    !,
    somma(Cont, 1, R), 
    R =< 43,
    pathZos2(Cs, Cs1, Is, R).
pathZos2(Cs, Cs, [], _C).

/* Metodo per la gestione della sintassi id8
   in particolare controllo della presenza delle
   due parentesi e richiamo al metodo per il controllo
   specifico della sintassi id8
*/
pathZos3([C | Cs], Cs1, Is, Cont1):-
    C == '(',
    !,
    %%% Inizializzazione contatore per lunghezza id8
    Cont1=0,
    %%% Richiamo metodo sintassi specifica id8
    pathZos4(Cs, [C2 | Cs1], Is1, Cont1), 
    append([C], Is1, IsA), 
    C2 == ')',
    append(IsA, [C2], Is).
pathZos3(Cs, Cs, [], _C).

%%% Metodo per controllare lunghezza e sintassi id8
pathZos4([C, C1 | Cs], Cs1, [C, C1 | Is], Cont1):-
    %%% Controllo che il primo carattere sia alfabetico
    is_alpha(C),
    is_alnum(C1), 
    !,
    somma(Cont1, 1, R), 
    %%% Controllo lunghezza id8
    R =< 7,  
    pathZos4(Cs, Cs1, Is, R). 
pathZos4(Cs, Cs, [], _C).

%%%metodo somma usato in pathZos
somma(X, Y, Z):-
    Z is (X + Y).

%%% Metodo per la gestione della query
queryQuestion([C | PathRest], QueryRest, Query) :-
    C == '?',
    !,
    %%% Richiamo al metodo per  sintassi di query
    queryId(PathRest, QueryRest, QueryProv),
    compress(QueryProv, Query).
queryQuestion(PathRest, PathRest, []).

%%% Metodo per la gestione di fragment 
fragmentHastag([C | QueryRest], FragmentRest, Fragment) :-
    C == '#', 
    !,
    %%% Richiamo metodo per sintassi di fragment 
    fragmentId(QueryRest, FragmentRest, FragmentProv),
    compress(FragmentProv, Fragment).
fragmentHastag(QueryRest, QueryRest, []).

/* Succesivamete ci sono una serie di metodi 
   per il controllo delle sintassi dei vari componenti
   dell'URI
*/
%%% Metodo identificazione stringa dello scheme
stringId([C | Cs], Cs1, [C | Is]) :- 
    C\='/',
    C\='?',
    C\='#',
    C\='@',
    C\=':',
    !, 
    stringId(Cs, Cs1, Is).
stringId(Cs, Cs, []).

/* Metodo per la gestione di Host nel caso di indirizzo IP 
   il metodo viene richiamato solo nel caso della presenza di 
   tutti e 15 i caratteri dell'indirizzo 
   Se l'indirizzo IP non dovesse essere completo si ricade nel caso
   di hostId "normale"
*/
hostId([N1, N2, N3, P1, N4, N5, N6, P2, N7, N8, N9, P3, N10, N11, N12 | Cs],
       Cs, 
       [N1, N2, N3, P1, N4, N5, N6, P2, N7, N8, N9, P3, N10, N11, N12]) :-
    %%% Vengono controllate le 4 terne di numeri 
    is_digit(N1),
    is_digit(N2),
    is_digit(N3),
    P1 == '.',
    is_digit(N4),
    is_digit(N5),
    is_digit(N6),
    P2 == '.',
    is_digit(N7),
    is_digit(N8),
    is_digit(N9),
    P3 == '.',
    is_digit(N10),
    is_digit(N11),
    is_digit(N12), 
    !,
    %%% Richiamo al metodo specifico per controllo IP
    ip([N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12]).

%%% Medodo identificazione stringa host
hostId([C | Cs], Cs1, [C | Is]) :- 
    C\='/',
    C\='?',
    C\='#',
    C\='@',
    C\=':',
    C\='.',
    !, 
    stringId(Cs, Cs1, Is).
hostId(Cs, Cs, []).

/* Metodo per il controllo delle terne di IP
  vengono richiamate 4 funzioni ognuna per ogni terna
*/
ip([N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12]) :-
    fun(N1, N2, N3), 
    fun(N4, N5, N6),
    fun(N7, N8, N9),
    fun(N10, N11, N12).

/* Funzione che trasforma la terna di numeri in
  un numero reale e controlla che sia compreso tra
  0 e 255 compresi
*/
fun(C1, C2, C3) :-
    atom_number(C1, N1),
    atom_number(C2, N2),
    atom_number(C3, N3),
    O = (N1 * 100 + N2 * 10 + N3), 
    digit(O).

%%% Controlla che il numero sia compreso tra 0 e 255
digit(C):-
    C >= 0,
    C =< 255.

%%% Metodo identificazione stringa path
pathId([C | Cs], Cs1, [C | Is]) :-
    C\='?',
    C\='#',
    C\='@',
    C\=':',
    C\='/',
    !, 
    pathId2(Cs, Cs1, Is).
pathId(Cs, Cs, []).

%%% Metodo identificazione stringa path
pathId2([C | Cs], Cs1, [C | Is]) :-
    C\='?',
    C\='#',
    C\='@',
    C\=':',
    !, 
    pathId2(Cs, Cs1, Is).
pathId2(Cs, Cs, []).

%%% Metodo identificazione stringa port
portId([C | Cs], Cs1, [C | Is]) :-
    is_digit(C),
    !, 
    portId(Cs, Cs1, Is).
portId(Cs, Cs, []).

%%% Metodo identificazione stringa query
queryId([C | Cs], Cs1, [C | Is]) :-
    C\='#', 
    !, 
    queryId(Cs, Cs1, Is).
queryId(Cs, Cs, []).

%%% Metodo identificazione stringa fragment
fragmentId([C | Cs], Cs1, [C | Is]) :-
    !, 
    fragmentId(Cs, Cs1, Is).
fragmentId(Cs, Cs, []).

%%%metodi per simboli singoli
duepunti([C | Lista], Lista) :-
    C == ':'.

at([C | Lista], Lista) :-
    C == '@'.

%%%metodo per trasformare una lista in una stringa
compress([], []) :- !.
compress(List, Result) :- 
    string_chars(List1, List), 
    atom_string(Result, List1). 
