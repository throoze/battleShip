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
    write('  Matthew Bace.'),nl,nl,
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
    write('Ingrese una cantidad de barcos valida\n>> '),
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
    cantBarcosValida(NB),
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
    P < B, B < T,
    !.

% tamanoValido(T) :- Pide por la entrada estándar, un valor para el tamaño
%                    de un barco, y verifica que sea válido. Si es inválido,
%                    vuelve a pedir el valor. Una vez obtenido un valor vá-
%                    lido, T queda instanciado a dicho valor.
tamanoValido(T) :-
    juego(F,C,_,_),
    repeat,
    write('Ingrese el Tamaño\n>> '),
    read(T),
    T =< F, T =< C,
    nl,!.

% orientacionValida(D) :-  Pide por la entrada estándar, un valor para la direc-
%                        ción de un barco, y verifica que sea válido. Si es in-
%                        válido, vuelve a pedir el valor. Una vez obtenido un
%                        valor válido, D queda instanciado a dicho valor.
orientacionValida(D) :-
    repeat,
    write('Ingrese la dirección\n>> '),
    read(D),nl,
    orientacionValidaAux(D).
% orientacionValidaAux(+D) :- Se satisface si D sea o h o v.
orientacionValidaAux(D) :- D = h.
orientacionValidaAux(D) :- D = v.

% obtenerFila(+F,+C,+M,+F1,Row) :- Se satisface si Row es la fila F1 del tablero
%                                  de tamaño FxC, M. Debe cumplirse que F1 <= F.
obtenerFila([H|T],0,Row) :-
    Row = H.
obtenerFila([H|T],F1,Row) :-
    F11 is F1 - 1,
    obtenerFila(T,F11,Row).

% obtenerElemento(+L,+I,E) :- Se satisface si E es el I-ésimo elemento de la
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

% obtenerColumna(+F,+C,+M,+C1,Col) :- Se satisface si Col es la columna C1 del
%                        tablero de tamaño FxC, M. Debe cumplirse que C1 <= C.
obtenerColumna(F,M,C1,Col) :-
    obtColAux()

% obtenerEspacio(+T,+D,+F1,+C1,L) :- Se satisface si L es una lista que repre-
%                       senta el contenido de las posiciones en el tablero de un
%                       barco de tamaño T, orientación D, y cuya proa esta en
%                       las coordenadas (F1,C1).
obtenerEspacio(T,h,F1,C1,L) :-
    disposicion(M),
    obtenerFila(M,F1,Row),
    obtenerEspacioAux(T,h,C1,Row,L).
obtenerEspacio(T,v,F1,C1,L) :-
    disposicion(M),
    obtenerColumna(F,M,C1,Col),
    obtenerEspacioAux(T,v,F1,Col,L).

% busqueda(+L,+E) :- Se satisface si el elemento E está en la lista L.
busqueda([],_) :- fail.
busqueda([E|T],E).
busqueda([_|T],E) :-
    busqueda(T,E).

% validarSolapamiento(T,D,F1,C1) :- Se satisface si el barco con el tamaño T, la
%                       orientación D, y cuya proa esta ubicada en las coordena-
%                       das (F1,C1) no se solapa con ningún barco previamente
%                       ubicado en el tablero.
validarSolapamiento(T,D,F1,C1) :-
    obtenerEspacio(T,D,F1,C1,L),
    not(busqueda(L,b)).

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
    validarSolapamiento(T,D,F1,C1).

% disposicionValida(+T,+D,F1,C1) :- Solicita por la entrada estándar un
%                       valor válido para la disposición de un barco en el ta-
%                       blero. Una vez obtenidos valores válidos, instancia F1 y
%                       C1 con dichos valores.
disposicionValida(T,D,F1,C1) :-
    repeat,
    write('Ingrese una Fila Inicial válida\n>> '),
    read(F1),nl,
    write('Ingrese la Columna Inicial\n>> '),
    read(C1),nl,
    validarDireccion(T,D,F1,C1),
    !.

% obtenerBarco(+F,+C) :- Pide al usuario por entrada estándar la información re-
%                        lativa a un barco en específico, y almacena en la base
%                        de conocimientos una estrucura que representa a dicho
%                        barco. Además, se asegura de que el barco sea válido
%                        para un tablero de dimensiones F filas y C columnas.
obtenerBarco(F,C) :- write('Información de barco:'),nl,
    tamanoValido(T),
    direccionValida(D),
    disposicionValida(F,C,T,D,F1,C1),
    assertz(barco(T,D,F1,C1,v)).

% obtenerBarcos(+F,+C,+NB) :- Se encarga de obtener de la entrada estándar,
%                         los parámetros que definen a cada barco, y almacenar
%                         éstos en la base de conocimientos del programa. F es
%                         el número de filas y C el número de columnas del ta-
%                         blero donde se jugará, y NB es el número de barcos a
%                         solicitar al usuario. Además, agrega a la base de co-
%                         nocimientos del programa una estructura que define los
%                         parámetros iniciales de la partida.
obtenerBarcos(F,C,NB) :- obtenerBarco(F,C),
    N1 is NB - 1,
    obtenerBarcos(F,C,N1).

% iniLista(+X,Y) :- Inicializa una lista Y de tamaño X con puras a (agua)
%                   dentro.
iniLista(0,Y):- Y=[],!.
iniLista(X,Y):-
    Y = [h|Ys],
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
    tableroInicial(TB),
    asserta(disposicion(TB)),
    obtenerBarcos(F,C,NB),
    obtenerNumBalas(F,C,B).%,
    tableroInicial(F,C,T),
    %hacerJugadas.

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
