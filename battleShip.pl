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

% jugar:- Se satisface una vez se ha obtenido las dimensiones del tablero, el
%         número de balas disponibles y la información de los barcos, se ha al-
%         macenado en la base de datos la información de los barcos, y se han
%         mostrado paso a paso cada uno de los movimientos realizados por su
%         programa hasta conseguir hundir todos los barcos colocados con el nú-
%         mero de balas disponibles. Puede que la secuencia de movimientos in-
%         cluya movimientos “hacia atras” en caso de que se agoten las balas an-
%         tes de alcanzar un estado final.

% tableroInicial(F, C, T):- Se satisface si T representa un tablero de F filas y
%                           C columnas donde todas sus posiciones corresponden a
%                           agua (posiciones donde no se sabe si existe o no
%                           barcos).

% mostrarTablero(T):- Muestra en pantalla una representación clara del estado
%                     actual del tablero T, diferenciando claramente las casi-
%                     llas con agua, fallos, barcos golpeados, y barcos hundidos
%                     (esto de acuerdo al formato indicado m ́s adelante).

% estadoFinal(T):- Se satisface si en T se han hundido todos los barcos origi-
%                  nalmente ocultos.

% ataque(+T0, T1, +F, +C):- Se satisface los tableros T0 y T1 corresponden a ta-
%                           bleros con F filas y C columnas, y T1 corresponde a
%                           realizar un disparo sobre el tablero T0.