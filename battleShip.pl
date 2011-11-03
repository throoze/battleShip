%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Universidad Simón Bolívar                                                    %
% Departamento de Computación y Tecnología de la Información                   %
% Laboratorio de Lenguajes de Programación I                                   %
% Septiembre-Diciembre 2011.                                                   %
% Profesora: Gabriela Montoya                                                  %
%                                                                              %
% Proyecto 1 del Laboratorio de Lenguajes de Programación I. Implementación    %
% del juego BattleShip Solitaire en Prolog. Para las especificaciones del pro- %
% yecto, ver el archivo "proyecto.pdf".                                        %
%                                                                              %
% Sinópsis:                                                                    %
%                                                                              %
%   Cargar el archivo en el interpretador swipl, y ejecutar el predicado jugar.%
% Seguir las instrucciones para ingresar la información de inicialización de   %
% la partida, y observar el desarrollo del juego. Recuerde ingresar el carac-  %
% ter punto (.) después de cada entrada al programa, i.e.:                     %
%                                                                              %
%       ?- jugar.                                                              %
%          Num. de Filas: 3.                                                   %
%          Num. de Columnas: 5.                                                %
%          Cant. de Barcos: 3.                                                 %
%                                                                              %
%   Carga del archivo:                                                         %
%                                                                              %
%       $ cd path/del/proyecto                                                 %
%       $ swipl                                                                %
%      ?- [battleShip.pl].                                                     %
%      ?- jugar.                                                               %
%                                                                              %
% Autores:                                                                     %
%                                                                              %
%    * Victor De Ponte, 05-38087, <victor.dpo@gmail.com>                       %
%    * Julio López, 06-39821, <julesallblack@gmail.com>                        %
%                                                                              %
% Versión: 1.0 - 28.10.2011                                                    %
% Archivo: battleShip.pl                                                       %
%                                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BASE DE CONOCIMIENTOS ESTÁTICA:

% BASE DE CONOCIMIENTOS DINÁMICA:
:- dynamic lista/1.
:- dynamic matriz/1.

% Estructura que guarda parámetros de inicialización de la partida. Éstos co-
% rresponden:
%   juego(#Filas, #Columnas, #Barcos, Suma de los tamaños de todos los barcos).
:- dynamic juego/4.

% Estructura que almacena las coordenadas de un disparo efectivo (que impactó en
% algún barco).
:- dynamic hit/2.

% Estructura que almacena la información relativa a las características de un
% barco en particular:
%                          barco(T,O,F,C,V)
% Donde: T = Tamaño del barco.
%        O = Orientación del barco.
%        F = Fila inicial del barco.
%        C = Columna inicial del barco.
%        v = Número de vidas restantes del barco.
:- dynamic barco/5.



% PREDICADOS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREDICADOS AUXILIARES %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% size(+L,N) :- Devuelve en N el tamaño de la lista L, usando recursión de cola.
%               Para ello, se vale del predicado auxiliar sizeAux.
size([],0).
size([X|Y],N) :-
    sizeAux([X|Y],N,0).
% sizeAux(L,N,Ac) :- Predicado auxiliar que nos devuelve en N el tamaño de la
%                    lista pasada como primer parámetro, usando recursión de co-
%                    la. Para ello, se vale del acumulador Ac.
% Caso Base: La lista contiene un sólo elemento. (Nunca será llamada con [],
%            porque es un predicado auxiliar).
sizeAux([_|[]],N,Ac) :-
    N is Ac + 1.
% Caso Recursivo: La lista contiene al menos 2 elementos.
sizeAux([_|[X|Y]],N,Ac) :-
    Ac1 is Ac + 1,
    sizeAux([X|Y],N,Ac1).

%mensajeBienvenida:- Imprime en pantalla un mensaje que da la bienvenida al
%                    usuario, e indica el comienzo del juego.
mensajeBienvenida :- write('                                     |__'),nl,
    write('                                     |\/'),nl,
    write('                                     ---'),nl,
    write('                                     / | ['),nl,
    write('                              !      | |||'),nl,
    write('                            _/|     _/|-++\''),nl,
    write('                        +  +--|    |--|--|_ |-'),nl,
    write('                     { /|__|  |/\\__|  |--- |||__/'),nl,
    write('                    +---------------___[}-_===_.\'____                 /\\'),nl,
    write('                ____`-\' ||___-{]_| _[}-  |     |_[___\\==--            \\/   _'),nl,
    write(' __..._____--==/___]_|__|_____________________________[___\\==--____,------\' .7'),nl,
    write('|              BIENVENIDO AL BATTLESHIP SOLITAIRE!!!!!!!!!            BB-61/'),nl,
    write(' \\_________________________________________________________________________|'),nl,
    write('WwWwWwWwWwwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWw'),nl,
    write(' Adaptación del ASCII art de Matthew Bace, por VD.'),nl,nl,
    write('Por Favor, para comenzar, introduzca la información solicitada...'),nl,
    write('Recuerde escribir un punto (.) después de cada valor introducido...'),
    nl,nl.

% dimensionValida(X,+D) :- Solicita por entrada estándar un valor válido para la
%                          dimensión del tablero especificada por D, e instancia
%                          X con dicho valor.
dimensionValida(X,D) :-
    repeat,
    write('Ingrese el Número de '),
    write(D),
    write(' (Un número entre 1 y 20)\n>> '),
    read(X),nl,
    1 =< X, X =< 20,!.

% cantBarcosValida(+F,+C,NB) :- Solicita por entrada estándar un valor válido
%                               para la cantidad de barcos a colocar en el ta-
%                               blero de tamaño FxC. Una vez obtenido un valor
%                               válido, instancia a NB con dicho valor.
cantBarcosValida(F,C,NB) :-
    repeat,
    write('Ingrese una cantidad de barcos válida\n>> '),
    read(NB),nl,
    N is F * C,
    1 =< NB,
    NB =< N,!.

% obtenerDimensiones(F,C,NB) :- Se encarga de pedirle al usuario las dimensiones
%                               del tablero con el que se va a jugar (F filas
%                               por C columnas).
obtenerDimensiones(F,C,NB) :-
    dimensionValida(F,'Filas'),
    dimensionValida(C,'Columnas'),
    cantBarcosValida(F,C,NB),
    asserta(juego(F,C,NB,0)).

% obtenerNumBalas(B) :- Se encarga de pedir al usuario el número de balas a ser
%                       utilizadas por el programa, e instancia a B con ese va-
%                       lor. En caso de no obtener un número de balas válido,
%                       lo solicita de nuevo.
obtenerNumBalas(B) :-
    repeat,
    write('Ingrese el Número de balas a utilizar\n>> '),
    read(B),nl,
    juego(F,C,_,P),
    T is F * C + 1,
    P =< B, B < T,
    !.

% actualizarLista(+L,+I,+E,Lf) :- Se satisface si Lf es una lista idéntica a L,
%                 exceptuando en el elemento en la posición I, donde el elemento
%                 original es sustituido por E.
actualizarLista(L,I,E,Lf) :-
    actualizarListaAux(I,[],E,L,Lf).
% actualizarListaAux(I,H,E,T,Lf) :- Se satisface si Lf es una lista idéntica a
%              L, exceptuando en el elemento en la posición I, donde el elemento
%              original es sustituido por E. H es una lista auxiliar que acumula
%              la cabeza recorrida de la lista. Utiliza recursión de cola.
actualizarListaAux(0,H,E,[_|T],Lf) :-
    Laux = [E|T],
    append(H,Laux,Lf),!.
actualizarListaAux(I,H,E,[E1|T],Lf) :-
    I1 is I - 1,
    append(H,[E1],Laux),
    actualizarListaAux(I1,Laux,E,T,Lf).

% actualizarMatriz(M,I,J,E,Mf) :- Se satisface cuando Mf es una matriz (lista de
%                listas) idéntica a M exceptuando en la posición (I,J) (0-index)
%                donde el elemento anterior fué sustituido por E.
actualizarMatriz(M,I,J,E,Mf) :-
    actualizarMatrizAux(I,J,[],M,E,Mf).
% actualizarMatrizAux(I,J,H,M,E,Mf) :- Se satisface cuando Mf es una matriz
%                (lista de listas) idéntica a M exceptuando en la posición (I,J)
%                (0-index) donde el elemento anterior fué sustituido por E. H es
%                una lista auxiliar que acumula las filas superiores de M. Uti-
%                liza recursión de cola.
actualizarMatrizAux(0,J,[],[F|T],E,Mf) :-
    actualizarLista(F,J,E,Fn),
    Mf = [Fn|T],
    !.
actualizarMatrizAux(0,J,H,[F|T],E,Mf) :-
    actualizarLista(F,J,E,Fn),
    Maux = [Fn|T],
    append(H,Maux,Mf),!.
actualizarMatrizAux(I,J,H,[F|T],E,Mf) :-
    I1 is I - 1,
    append(H,[F],Maux),
    actualizarMatrizAux(I1,J,Maux,T,E,Mf).

% obtenerFila(+F,+C,+M,+F1,Row) :- Se satisface si Row es la fila F1 del tablero
%                                  de tamaño FxC, M. Debe cumplirse que F1 <= F.
obtenerFila([H|_],0,Row) :-
    Row = H.
obtenerFila([_|T],F1,Row) :-
    F11 is F1 - 1,
    obtenerFila(T,F11,Row).

% obtenerElemLista(+L,+I,E) :- Se satisface si E es el I-ésimo elemento de la
%                             lista L. Debe cumplirse: size(L,N), 0 =< I, I < N.
obtenerElemLista([E|_],0,E).
obtenerElemLista([_|T],I,E) :-
    I1 is I - 1,
    obtenerElemLista(T,I1,E).

% obtenerElemMatriz(M,F,C,E) :- Se satisface si E es el elemento en la F-ésima
%                               fila, en la C-ésima columna de la lista de lis-
%                               tas (Matriz) M. Debe cumplirse: 0 =< F, 0 =< C,
%                               M = [H|T], size(M,Nf), size(H,Nc), F =< Nf,
%                               C =< Nc.
obtenerElemMatriz(M,F,C,E) :-
    obtenerElemLista(M,F,Fila),
    obtenerElemLista(Fila,C,E).

% obtenerColumna(+F,+M,+C,Col) :- Se satisface si Col es la columna C del
%                        tablero con F filas, M. Debe cumplirse que 0 =< C.
obtenerColumna(F,M,C,Col) :-
    obtColAux(F,F,M,C,[],Col).
% obtColAux(+F1,+F,+M,+C,Col) :- Se satisface si Col es la columna C del
%                        tablero con F filas, M. Debe cumplirse que 0 =< C.
obtColAux(0,_,_,_,Laux,Col) :-
    Laux = Col,!.
obtColAux(F1,F,M,C,Laux,Col) :-
    I is F - F1,
    F2 is F1 - 1,
    obtenerElemMatriz(M,I,C,E),
    append(Laux,[E],NLaux),
    obtColAux(F2,F,M,C,NLaux,Col).

% colaLista(+I,+L,T) :- Se satisface si T es la cola de la lista L comenzando en
%                       la posicion I.
colaLista(I,L,T) :-
    colaListaAux(0,I,L,T).
% colaListaAux(+N,+I,+L,T) :- Predicado auxiliar que utiliza recursión de cola.
%                             Se satisface si T es la cola comenzando en la po-
%                             sicion I de la Lista L. N es un contador auxiliar,
%                             La primera llamada a este predicado debe hacerse
%                             con N = 0.
colaListaAux(I,I,L,T) :-
    T = L,!.
colaListaAux(N,I,[_|Xs],T) :-
    N1 is N + 1,
    colaListaAux(N1,I,Xs,T).

% cabezaLista(+T,+L,H) :- Se satisface si H es la cabeza de tamaño T de la lista
%                         L.
cabezaLista(T,L,H) :-
    cabezaListaAux(T,L,[],H).
% cabezaListaAux(+T,+L,+Laux,H) :- Predicado auxiliar que usa recursión de cola.
%                                  Se satisface si H es la cabeza de la lista L.
%                                  T es un contador auxiliar que debe empezar
%                                  con valor 0, y Laux es una lista acumuladora
%                                  auxiliar que debe empezar con valor [].
cabezaListaAux(0,_,Laux,H) :-
    Laux = H,!.
cabezaListaAux(T,[X|Xs],Laux,H) :-
    T1 is T - 1,
    append(Laux,[X],Laux1),
    cabezaListaAux(T1,Xs,Laux1,H).

% subLista(+I,+T,+L,SL) :- Se satisface si SL es la lista contenida en L, que
%                          comienza en la posición I, de tamaño T.
subLista(I,T,L,SL) :-
    colaLista(I,L,Laux),
    cabezaLista(T,Laux,SL).

% obtenerEspacio(+T,+D,+F1,+C1,L) :- Se satisface si L es una lista que repre-
%                       senta el contenido de las posiciones en el tablero de un
%                       barco de tamaño T, orientación D, y cuya proa esta en
%                       las coordenadas (F1,C1).
obtenerEspacio(T,h,F1,C1,L) :-
    disposicion(M),
    obtenerFila(M,F1,Row),
    subLista(C1,T,Row,L),!.
obtenerEspacio(T,v,F1,C1,L) :-
    disposicion(M),
    juego(F,_,_,_),
    obtenerColumna(F,M,C1,Col),
    subLista(F1,T,Col,L),!.


% busqueda(+L,+E) :- Se satisface si el elemento E está en la lista L.
busqueda([],_) :- fail.
busqueda([E|_],E).
busqueda([_|T],E) :-
    busqueda(T,E).

% validarSolapamiento(+T,+D,+F1,+C1) :- Se satisface si el barco con el tamaño
%                       T, la orientación D, y cuya proa esta ubicada en las co-
%                       ordenadas (F1,C1) no se solapa con ningún barco previa-
%                       mente ubicado en el tablero.
validarSolapamiento(T,D,F1,C1) :-
    obtenerEspacio(T,D,F1,C1,L),
    not(busqueda(L,b)),!.

% validarDireccion(+T,+D,+F1,+C1) :- Se satisface si el barco de tamaño T, con
%                                la orientación D, cuya proa está ubicada en las
%                                coordendas (F1,C1) "cabe" en el tablero confi-
%                                gurado para la partida, las coordenadas (F1,C1)
%                                son no negativas, y no hay ningun otro barco
%                                ubicado en alguna posición que toque el barco
%                                que está siendo validado.
validarDireccion(T,D,F1,C1) :-
    juego(F,C,_,_),
    0 =< F1, F1 < F,
    0 =< C1, C1 < C,
    validarSolapamiento(T,D,F1,C1),!.

% tamanoValido(T) :- Pide por la entrada estándar, un valor para el tamaño
%                    de un barco, y verifica que sea válido. Si es inválido,
%                    vuelve a pedir el valor. Una vez obtenido un valor vá-
%                    lido, T queda instanciado a dicho valor.
tamanoValido(T) :-
    juego(F,C,_,_),
    T =< F, T =< C,
    nl,!.

% orientacionValida(+D) :-  Pide por la entrada estándar, un valor para la di-
%                        rección de un barco, y verifica que sea válido. Si es
%                        inválido, vuelve a pedir el valor. Una vez obtenido un
%                        valor válido, D queda instanciado a dicho valor.
orientacionValida(v).
orientacionValida(h).

% disposicionValida(-T,-D,-F1,-C1) :- Solicita por la entrada estándar valores
%                       válidos para la disposición de un barco en el tablero.
%                       Una vez obtenidos valores válidos, instancia F1 y C1 con
%                       dichos valores.
disposicionValida(T,D,F,C) :-
    repeat,
    write('Ingrese el Tamaño\n>> '),
    read(T),nl,
    write('Ingrese la orientación\n>> '),
    read(D),nl,
    write('Ingrese una Fila Inicial válida\n>> '),
    read(F),nl,
    write('Ingrese la Columna Inicial\n>> '),
    read(C),nl,
    tamanoValido(T),
    orientacionValida(D),
    validarDireccion(T,D,F,C),
    !.

% posicionarBarcoVertical(+T,+F,+C,+TB,NTB) :- Se satisface si el tablero (lista
%                de listas) NTB es el resultado de colocar el barco de tamaño T,
%                orientación Vertical, cuya primera casilla está en las coorde-
%                nadas (F,C) en el tablero (lista de listas) de TB.
posicionarBarcoVertical(0,_,_,TB,NTB) :-
    NTB = TB,!.
posicionarBarcoVertical(T,F,C,TB,NTB) :-
    Tn is T - 1,
    Fn is F + 1,
    actualizarMatriz(TB,F,C,b,Tacc),
    posicionarBarcoVertical(Tn,Fn,C,Tacc,NTB).

% posicionarBarcoHorizontal(+T,+F,+C,+TB,NTB) :- Se satisface si el tablero
%            (lista de listas) NTB es el resultado de colocar el barco de tamaño
%            T, orientación Horizontal, cuya primera casilla está en las coorde-
%            nadas (F,C) en el tablero (lista de listas) de TB.
posicionarBarcoHorizontal(0,_,_,TB,NTB) :-
    NTB = TB,!.
posicionarBarcoHorizontal(T,F,C,TB,NTB) :-
    Tn is T - 1,
    Cn is C + 1,
    actualizarMatriz(TB,F,C,b,Tacc),
    posicionarBarcoVertical(Tn,F,Cn,Tacc,NTB).

% posicionarBarco(+T,+D,+F,+C,+TB,NTB) :- Se satisface si el tablero (lista de
%                     listas) NTB es el resultado de colocar el barco de tamaño
%                     T, orientación D, cuya primera casilla está en las coorde-
%                     nadas (F,C) en el tablero (lista de listas) de TB.
posicionarBarco(T,v,F,C,TB,NTB) :-
    posicionarBarcoVertical(T,F,C,TB,NTB).
posicionarBarco(T,h,F,C,TB,NTB) :-
    posicionarBarcoHorizontal(T,F,C,TB,NTB).

% obtenerBarco :- Pide al usuario por entrada estándar la información re-
%                 lativa a un barco en específico, y almacena en la base
%                 de conocimientos una estrucura que representa a dicho
%                 barco.
obtenerBarco :-
    write('Información de barco:'),nl,
    disposicionValida(T,D,F,C),
    % Agrego al barco a la BD
    assertz(barco(T,D,F,C,T)),
    retract(disposicion(TB)),
    % Coloco el barco en el tablero de barcos
    posicionarBarco(T,D,F,C,TB,NTB),
    asserta(disposicion(NTB)),
    % Actualizo los parámetros de la partida
    retract(juego(X1,X2,X3,NPB)),
    NPBn is NPB + T,
    assertz(juego(X1,X2,X3,NPBn)),
    write('Barco agregado con éxito!\n\n'),!.

% obtenerBarcos(+NB) :-   Se encarga de obtener de la entrada estándar,
%                         los parámetros que definen a cada barco, y almacenar
%                         éstos en la base de conocimientos del programa. F es
%                         el número de filas y C el número de columnas del ta-
%                         blero donde se jugará, y NB es el número de barcos a
%                         solicitar al usuario. Además, agrega a la base de co-
%                         nocimientos del programa una estructura que define los
%                         parámetros iniciales de la partida.
obtenerBarcos(0) :- !.
obtenerBarcos(NB) :-
    N1 is NB - 1,
    obtenerBarco,
    obtenerBarcos(N1).

% iniLista(+X,Y) :- Inicializa una lista Y de tamaño X con puras a (agua)
%                   dentro.
iniLista(0,Y):- Y=[],!.
iniLista(X,Y):-
    Y = [a|Ys],
    X1 is X-1,
    iniLista(X1,Ys).

% impLista(L) :- Imprime en pantalla una lista L elemento por elemento.
impLista([]).
impLista(L):-
    L= [X|Y],
    write(X),
    impLista(Y).

% esHlista(h,+N,N1) :-  Si un elemento de una lista es una h suma uno a N
%                       y lo devuelve en N1.
esHlista(h,N,N1):-
    N1 is N+1,
    !.
esHlista(_,_,_):- !.

% iterLista(+L,N) :-    Recorre una lista L contando cuantos elementos son h
%                       (hundido) y devuelve el número total de h en N.
iterLista([],_).
iterLista(L,N):-
    itLaux(L,N,0).

% itLaux(+L,N,+Ac) :-   Auxiliar de iterLista, para llevar un acumulador
%                       Ac en la recursión.
itLaux([X|[]],N,Ac):-
    esHlista(X,Ac,Ac1),
    N = Ac1,
    !.
itLaux(L,N,Ac):-
    L = [Z|[X|Y]],
    esHlista(Z,Ac,Ac1),
    itLaux([X|Y],N,Ac1).

% manejadorDisparoABarco(+T0,+X,+Y,+T,+O,+F,+C,T1) :- Se satisface cuando se han
%   tomado las desiciones correctas al recibir las coordenadas (X,Y) de un dis-
%   paro que se asume, pertenecen a algún barco, y se actualiza el tablero de
%   acuerdo a las decisiones tomadas.
manejadorDisparoABarco(T0,X,Y,T,O,F,C,T1) :-
    barco(T,O,F,C,V),
    perteneceAlBarco(X,Y,T,O,F,C),
    retract(barco(T,O,F,C,V)),
    V1 is V - 1,
    assertz(barco(T,O,F,C,V1)),
    hayQueHundirlo(T0,X,Y,T,O,F,C,V,T1).

% perteneceAlBarco(+X,+Y,+T,+O,+F,+C) :- Se satisface si la casilla de coordena-
%               das (X,Y) pertenece al barco de tamaño T, orientación O, cuya
%               fila inicial es X, y su columna inicial es Y.
perteneceAlBarco(X,Y,T,O,F,C) :-
    pertBarcAux(X,Y,T,O,F,C).

% pertBarcAux(+X,+Y,+T,+O,+F,+C) :- Se satisface si la casilla de coordenadas
%               (X,Y) pertenece al barco de tamaño T, orientación O, cuya fila
%               inicial es X, y su columna inicial es Y. Es un predicado auxi-
%               liar de perteneceAlBarco/6, especializado según la orientación.
pertBarcAux(X,Y,T,v,F,C) :-
    Ff is F + T,
    F =< X, X < Ff,
    Y = C.
pertBarcAux(X,Y,T,h,F,C) :-
    Cf is C + T,
    C =< Y, Y < Cf,
    X = F.

% golpearBarco(+X,+Y,+T0,+T,+O,+F,+C,T1) :- Se satisface si el tablero T1 es
%  idéntico al tablero T0, excepto en una sóla casilla (X,Y) perteneciente al
%  barco de tamaño T, orientación O, coordenadas iniciales (F,C).
golpearBarco(T0,X,Y,T,O,F,C,T1) :-
    actualizarMatriz(T0,X,Y,g,T1),
    !.

% hundirBarco(+T0,+T,+O,+F,+C,T1) :- Se satisface si el tablero T1 es idéntico
%        al tablero T0, exceptuando en las casillas pertenecientes al barco de
%        tamaño T, orientación O, coordenadas iniciales (F,C), las cuales serán
%        actualizadas a "h", en representación de un barco hundido.
hundirBarco(T0,T,O,F,C,T1) :-
    hundirBarcoAux(T0,T,O,F,C,T1).

% hundirBarcoAux(+T0,+T,+O,+F,+C,T1) :- Se satisface si el tablero T1 es idénti-
%       co al tablero T0, exceptuando en las casillas pertenecientes al barco de
%       tamaño T, orientación O, coordenadas iniciales (F,C), las cuales serán
%       actualizadas a "h", en representación de un barco hundido.
hundirBarcoAux(T0,T,v,F,C,T1) :-
    hundirBarcoVertical(T0,T,F,C,T1).
hundirBarcoAux(T0,T,h,F,C,T1) :-
    hundirBarcoHorizontal(T0,T,F,C,T1).

% hundirBarcoVertical(+T0,+T,+F,+C,T1) :- Se satisface si el tablero T1 es idén-
%    tico al tablero T0, exceptuando en las casillas pertenecientes al barco de
%    tamaño T, orientación Vertical, coordenadas iniciales (F,C), las cuales se-
%    rán actualizadas a "h", en representación de un barco hundido.
hundirBarcoVertical(T0,0,_,_,T1) :-
    T1 = T0,!.
hundirBarcoVertical(T0,T,F,C,T1) :-
    Tn is T - 1,
    Fn is F + 1,
    actualizarMatriz(T0,F,C,h,Tacc),
    hundirBarcoVertical(Tacc,Tn,Fn,C,T1).

% hundirBarcoHorizontal(+T0,+T,+F,+C,T1) :- Se satisface si el tablero T1 es
%    idéntico al tablero T0, exceptuando en las casillas pertenecientes al barco
%    de tamaño T, orientación Horizontal, coordenadas iniciales (F,C), las cua-
%    les serán actualizadas a "h", en representación de un barco hundido.
hundirBarcoHorizontal(T0,0,_,_,T1) :-
    T1 = T0,!.
hundirBarcoHorizontal(T0,T,F,C,T1) :-
    Tn is T - 1,
    Cn is C + 1,
    actualizarMatriz(T0,F,C,h,Tacc),
    hundirBarcoVertical(Tacc,Tn,F,Cn,T1).

% hayQueHundirlo(+T0,+X,+Y,+T,+O,+F,+C,+V,T1) :- Decide si actualizar el tablero
%  T0 para hundir el barco por completo, o si sólo será golpeado, dependiendo de
%  las vidas restantes del barco de tamaño T, orientación O, coordenadas inicia-
%  les (F,C) con V vidas restantes (casillas intactas). El tablero actualizado
%  unifica con T1.
hayQueHundirlo(T0,X,Y,T,O,F,C,0,T1) :-
    hundirBarco(T0,T,O,F,C,T1).
hayQueHundirlo(T0,X,Y,T,O,F,C,_,T1) :-
    golpearBarco(T0,X,Y,T,O,F,C,T1).

%%%%%%%%%%%%%%%%%%%% PREDICADOS REQUERIDOS POR EL ENUNCIADO %%%%%%%%%%%%%%%%%%%%

% jugar :- Se satisface una vez se ha obtenido las dimensiones del tablero, el
%          número de balas disponibles y la información de los barcos, se ha al-
%          macenado en la base de datos la información de los barcos, y se han
%          mostrado paso a paso cada uno de los movimientos realizados por su
%          programa hasta conseguir hundir todos los barcos colocados con el nú-
%          mero de balas disponibles. Puede que la secuencia de movimientos in-
%          cluya movimientos “hacia atras” en caso de que se agoten las balas
%          antes de alcanzar un estado final.
jugar :-
    mensajeBienvenida,
    obtenerDimensiones(F,C,NB),
    tableroInicial(F,C,TB),
    asserta(disposicion(TB)),
    obtenerBarcos(NB),
    disposicion(Tablero),
    mostrarTablero(Tablero),
    obtenerNumBalas(B),
    tableroInicial(F,C,T),
    %hacerJugadas(B,T),
    retractall(barco(_,_,_,_,_)).

% tableroInicial(F,C,T) :- Se satisface si T representa un tablero de F filas
%                           y C columnas donde todas sus posiciones corresponden
%                           a agua (posiciones donde no se sabe si existe o no
%                           barcos).
tableroInicial(0,_,T):- T=[],!.
tableroInicial(F,C,T):-
    iniLista(C,Y),
    T = [Y|Ts],
    F1 is F-1,
    tableroInicial(F1,C,Ts).

% mostrarTablero(T) :- Muestra en pantalla una representación clara del estado
%                      actual del tablero T, diferenciando claramente las casi-
%                      llas con agua, fallos, barcos golpeados, y barcos hundi-
%                      dos.
mostrarTablero([]).
mostrarTablero(T):-
    T = [X|Y],
    impLista(X),
    nl,
    mostrarTablero(Y).

% estadoFinal(T) :- Se satisface si en T se han hundido todos los barcos origi-
%                   nalmente ocultos.
estadoFinal(T):-
    estadoFinalAux(T,N,0),
    juego(_,_,_,O),
    O = N,
    !.
estadoFinalAux([X|[]],N,Ac):-
    iterLista(X,Nn),
    N is Ac + Nn,
    !.
estadoFinalAux(T,N,Ac):-
    T= [X|Y],
    iterLista(X,Nn),
    Ac1 is Ac+Nn,
    estadoFinalAux(Y,N,Ac1).

% ataque(+T0, T1, +F, +C) :- Se satisface los tableros T0 y T1 corresponden a
%                           tableros con F filas y C columnas, y T1 corresponde
%                           a realizar un disparo sobre el tablero T0.
