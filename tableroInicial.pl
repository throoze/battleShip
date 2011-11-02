juego(a,b,c,15).
:- dynamic disparo/2.
disparo(2,1).
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
% Recorre lista L elemento a elemento.
% Lac tiene los valores anteriores al de la posicion Pc, Lf es donde kiero devolver algo que todavia no tengo claro, L tiene siempre la cola de la lista
% inicial.
actLista(L,Pc,Lf,E):-
	actListaAux(L,Pc,[],Lf,E).
	
actListaAux(L,0,Lac,Lf,E):-
	L= [_|Y],
	Lo= [E|Y],% aca hacer verificación de si es agua pongo f si es barco g.
	append(Lac,Lo,Lf),
	!.
	
actListaAux(L,Pc,Lac,Lf,E):-
	L= [X|Y],
	append(Lac,[X],Laux),
	Pc1 is Pc-1,
	actListaAux(Y,Pc1,Laux,Lf,E).	

% Recorre lista de listas L0, hasta la posición Pf, luego llama a actLista.
actListaLista(L0,L1,Pf,Pc,E):-
	actListaListaAux(L0,L1,Pf,Pc,[],E).
actListaListaAux(L0,L1,0,Pc,[],E):-
	write('VACIO'),
	nl,
	L0= [X|Y],
	actLista(X,Pc,Lf,E),
	Ln= [Lf|Y],
	L1 = Ln,
	!.
actListaListaAux(L0,L1,0,Pc,Lcon,E):-
	write('NO VACIO'),nl,
	L0= [X|Y],
	actLista(X,Pc,Lf,E),
	Ln= [Lf|Y],
	Lconx = [Lcon],
	append(Lconx,Ln,L1),
	!.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% el peo está en lista lista recursiva
actListaListaAux(L0,L1,Pf,Pc,[],E):-
	L0 = [X|Y],
	Pf1 is Pf-1,
	actListaListaAux(Y,L1,Pf1,Pc,X,E),
	!.
actListaListaAux(L0,L1,Pf,Pc,Lcon,E):-
	L0= [X|Y],
	append(Lcon,X,Lcon1),
	Pf1 is Pf-1,
	actListaListaAux(Y,L1,Pf1,Pc,Lcon1,E).
	
% Si es a cambia por f, si es b cambia por g
esAoB(a,L0,L1,Pf,Pc):-
	%actListaLista(L0,L1,Pf,Pc,f),
	
	!.
esAoB(b,L0,L1,Pf,Pc):-
	%actListaLista(L0,L1,Pf,Pc,g),
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
		
% Hace la jugada en general, osea hace varios ataques
hacerJugadas(T0,T1,F,C):-
	ataque(T0,T1,F,C),
	retract(disparo(X,Y)),
	siguienteDisparo(X,Y,X1,Y1,C),
	assertz(disparo(X1,Y1)).
	

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
	hacerJugadas(T,T1,3,5),
	nl,
	mostrarTablero(T1),
	nl,
	hacerJugadas(T1,T2,3,5),
	mostrarTablero(T2),
	nl,
	hacerJugadas(T2,T3,3,5),
	nl,
	mostrarTablero(T3).