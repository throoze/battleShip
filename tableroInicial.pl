juego(a,b,c,15).
:- dynamic disparo/2.
:- dynamic hit/2.
disparo(0,0).
disposicion([[a,b,a,a,a],[a,b,b,a,a],[a,a,a,a,a]]).

% Inicializa una lista Y de tamaño X con puras 'a' dentro
iniLista(0,Y):- Y=[],!.
iniLista(X,Y):- 
	Y = [a|Ys],
	X1 is X-1,
	iniLista(X1,Ys).
	
% Inicializa el tablero visible de la partida T con F filas C columnas
tableroInicial(0,_,T):- T=[],!.
tableroInicial(F,C,T):- 
	iniLista(C,Y),
	T = [Y|Ts],
	F1 is F-1,
	tableroInicial(F1,C,Ts).
	
% Imprime en pantalla una lista
impLista([]):- !.
impLista(L):-
	L= [X|Y],
	write(X),
	impLista(Y).

% Muestra en pantalla el estado actual del tablero de juego
mostrarTablero([]):- !.
mostrarTablero(T):-
	T = [X|Y],
	impLista(X),
	nl,
	mostrarTablero(Y).

% Si un elemento de una lista es una h suma uno a N
esHlista(h,N,N1):- 
	N1 is N+1,
	!.
esHlista(_,_,_):- !.
	
% Recorre una lista L elemento por elemento
iterLista([],_).
iterLista(L,N):-
	itLaux(L,N,0).
	
% Auxiliar de iterLista, para llevar un acumulador en la recursión
itLaux([X|[]],N,Ac):-
	esHlista(X,Ac,Ac1),
	N = Ac1,
	!.
itLaux(L,N,Ac):-
	L = [Z|[X|Y]],
	esHlista(Z,Ac,Ac1),
	itLaux([X|Y],N,Ac1).

% Indica si se hundieron todos los barcos, se satisface si el número de posiciones iniciales de los barcos es igual al número de h´s en el tablero
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
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parte 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% codigo victor

% actualizarLista(+L,+I,+E,Lf) :- Se satisface si Lf es una lista idéntica a L,
%                 exceptuando en el elemento en la posición I, donde el elemento
%                 original es sustituido por E.
actualizarLista(L,I,E,Lf) :-
    actualizarListaAux(I,[],E,L,Lf).
% actualizarListaAux(I,H,E,T,Lf) :- Se satisface si Lf es una lista idéntica a
%              L, exceptuando en el elemento en la posición I, donde el elemento
%              original es sustituido por E. H es una lista auxiliar que acumula
%              la cabeza recorrida de la lista.
actualizarListaAux(0,H,E,[_|T],Lf) :-
    Laux = [E|T],
    append(H,Laux,Lf),!.
actualizarListaAux(I,H,E,[E1|T],Lf) :-
    I1 is I - 1,
    append(H,[E1],Laux),
    actualizarListaAux(I1,Laux,E,T,Lf).

% actualizarMatriz(M,I,J,E,Mf) :-
actualizarMatriz(M,I,J,E,Mf) :-
    actualizarMatrizAux(I,J,[],M,E,Mf).
% actualizarMatrizAux(I,J,H,M,E,Mf) :-
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Si es a cambia por f, si es b cambia por g
esAoB(a,L0,L1,Pf,Pc):-
	actualizarMatriz(L0,Pf,Pc,f,L1),
	!.
esAoB(b,L0,L1,Pf,Pc):-
	asserta(hit(Pf,Pc)),
	actualizarMatriz(L0,Pf,Pc,g,L1),
	!.

% Dibuja el resultado del ataque a T0 en T1
ataque(T0,T1,_,_):- 
	disparo(Df,Dc),
	disposicion(Tt),
	obtenerElemMatriz(Tt,Df,Dc,E),
	esAoB(E,T0,T1,Df,Dc),
	!.

% ve si X llego al borde del tablero, la pone en 0, suma 1 a Y, de lo contrario solo suma 1 a X.
siguienteDisparo(X,Y,X1,Y1,C):-
	Yn is Y,
	Yz is C-Yn,
	dentroTablero(Yz,X,Y,X1,Y1).

% Auxiliar de siguienteDisparo
dentroTablero(1,X,_,X1,Y1):-
	Y1 = 0,
	X1 is X+1.
	
dentroTablero(_,X,Y,X1,Y1):-
	Y1 is Y+1,
	X1 is X,
	!.
		
% Hace la jugada en general,
hacerJugada(T0,T1,F,C):-
	ataque(T0,T1,F,C),
	retract(disparo(X,Y)),
	siguienteDisparo(X,Y,X1,Y1,C),
	assertz(disparo(X1,Y1)).
% Llama tantas veces como balas haya a hacerJugada.
hacerJugadas(0,_,_,_,_):-
	fail,
	!.	
hacerJugadas(B,T0,T1,F,C):-
	hacerJugada(T0,T1,F,C),
	write(B),
	nl,
	mostrarTablero(T1),
	nl,
	B1 is B-1,
	hacerJugadas(B1,T1,T2,F,C).
	

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
	
	
	
imprimir:-
	tableroInicial(3,5,T),
	mostrarTablero(T),
	nl,
	hacerJugadas(15,T,T1,3,5).
	%hacerJugada(T,T1,3,5),
	%mostrarTablero(T1),
	%nl,
	%hacerJugada(T1,T2,3,5),
	%mostrarTablero(T2),
	%nl,
	%hacerJugada(T2,T3,3,5),
	%mostrarTablero(T3),
	%nl.