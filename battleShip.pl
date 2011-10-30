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

% obtenerDimensiones(F,C,NB) :- Se encarga de pedirle al usuario las dimensiones
%                               del tablero con el que se va a jugar (F filas
%                               por C columnas).
obtenerDimensiones(F,C,NB) :-
    dimensionValida(F,'Filas'),
    dimensionValida(C,'Columnas'),
    write('Ingrese el Número de Filas\n>> '),
    read(F),nl,write('Ingrese el Número de Columnas\n>> '),
    read(C),nl,write('Ingrese el Número de Barcos\n>> '),
    read(NB),nl.

dimensionValida(X,D) :-
    write('Ingrese el Número de'),
    write(D),
    write('\n>> '),
    read(X),nl,
    1 <= X, X <= 20.

cantBarcosValida(NB) :-
    write('Ingrese el Número de Barcos\n>> '),
    read(NB),nl.
    % VERIFICAR QUE SEA VALIDO

% obtenerNumBalas(B) :- Se encarga de pedir al usuario el número de balas a ser
%                       utilizadas por el programa, e instancia a B con ese va-
%                       lor.
obtenerNumBalas(B) :- write('Ingrese el Número de balas a utilizar\n>> '),nl,
    read(B),nl.

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

% obtenerBarco(+F,+C) :- Pide al usuario por entrada estándar la información re-
%                        lativa a un barco en específico, y almacena en la base
%                        de conocimientos una estrucura que representa a dicho
%                        barco. Además, se asegura de que el barco sea válido
%                        para un tablero de dimensiones F filas y C columnas.
obtenerBarco(F,C) :- write('Información de barco:'),nl,
    tamanoValido(T,F,C),
    direccionValida(D),
    disposicionValida(F,C,T,D,F1,C1),
    assertz(barco(T,D,F1,C1,v)).

tamanoValido(T,F,C) :-
    write('Ingrese el Tamaño\n>> ')
    read(T),nl,
    % VERIFICAR QUE SEA VALIDO

direccionValida(D) :-
    write('Ingrese la dirección\n>> ')
    read(D),nl,
    % VERIFICAR QUE SEA VALIDO

disposicionValida(F,C,T,D,F1,C1) :-
    write('Ingrese una Fila Inicial válida\n>> ')
    read(F1),nl,
    write('Ingrese la Columna Inicial\n>> ')
    read(C1),nl,
    % VERIFICAR QUE SEA VALIDO

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
    obtenerBarcos(F,C,NB),
    %tableroInicial(TB),
    %asserta(disposicion(TB)),
    obtenerNumBalas(F,C,B).%,
    %tableroInicial(F,C,T),
    %hacerJugadas().

% tableroInicial(F, C, T) :- Se satisface si T representa un tablero de F filas
%                           y C columnas donde todas sus posiciones corresponden
%                           a agua (posiciones donde no se sabe si existe o no
%                           barcos).

% mostrarTablero(T) :- Muestra en pantalla una representación clara del estado
%                      actual del tablero T, diferenciando claramente las casi-
%                      llas con agua, fallos, barcos golpeados, y barcos hundi-
%                      dos.

% estadoFinal(T) :- Se satisface si en T se han hundido todos los barcos origi-
%                   nalmente ocultos.

% ataque(+T0, T1, +F, +C) :- Se satisface los tableros T0 y T1 corresponden a
%                           tableros con F filas y C columnas, y T1 corresponde
%                           a realizar un disparo sobre el tablero T0.