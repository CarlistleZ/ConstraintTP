:-lib(branch_and_bound).
/*Q6.1*/
:-lib(ic).

poids([](24, 39, 85, 60, 165, 6, 32, 123, 7, 14)).

sieges(S):-
	dim(S, [10]),
	S #:: [ -8 .. -1, 1 .. 8].

vecProduct(V1, V2, VRes):- 
    dim(V1,[D]),
    dim(V2,[D]),
    dim(VRes,[D]),
    (foreacharg(Elt1,V1), foreacharg(Elt2,V2), foreacharg(EltRes,VRes) do
        EltRes #= Elt1 * Elt2
    ).

vecSum(Vec,Sum):-(
    foreacharg(Elt,Vec), fromto(0,In,Out,Sum) do
        Out #= In + Elt
    ).

vecDotProduct(V1, V2, S):-
    vecProduct(V1, V2, TmpVec),
    vecSum(TmpVec, S).

countPositif(V,Res):-
	(
		foreacharg(Elt,V), 
		fromto(0,In,Out,Res) 
		do
		(Elt #> 0) => (Out #= In +1),
		(Elt #=< 0) => (Out #= In) 
    ).

%On sait que s'il y en a 5 à droite il y en aura 5 à gauche
nbDroite(V):-
	countPositif(V,C),
	C #= 5.

equilibre(S, P):-
	vecDotProduct(S, P, 0).

parentsAuBout(S):-
	Lou is S[4],
	Tom is S[8],
	ic:max(S, Lou),
	ic:min(S, Tom).

enfantsAvecParents(S):-
	Lou is S[4],
	Tom is S[8],
	Dan is S[6],
	Max is S[9],
	(Dan #= Tom + 1 and Max #= Lou - 1)
	or
	(Dan #= Lou - 1 and Max #= Tom + 1).

constraints(S, P):-
	equilibre(S, P),
	parentsAuBout(S),
	enfantsAvecParents(S),
	nbDroite(S),
	alldifferent(S).

solve(Sieges):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	labeling(Sieges).

/*Q6.2*/
/*
solve(S).

S = [](-6, -5, -1, 8, 5, 7, 3, -8, -7, 1)
Yes (0.01s cpu, solution 1, maybe more) ? ;

S = [](-6, -5, 2, 8, 4, -7, -2, -8, 7, 5)
Yes (0.01s cpu, solution 2, maybe more) ? ;

S = [](-6, -5, 2, 8, 4, 7, -2, -8, -7, 6)
Yes (0.01s cpu, solution 3, maybe more) ? ;

S = [](-6, -5, 5, 7, 3, 6, -1, -8, -7, 2)
Yes (0.02s cpu, solution 4, maybe more) ? ;

S = [](-6, -5, 6, 8, 2, 7, -1, -8, -7, 3)
Yes (0.03s cpu, solution 5, maybe more) ? ;

S = [](-6, -4, -2, 8, 5, -7, 4, -8, 7, 1)
Yes (0.04s cpu, solution 6, maybe more) ?
*/

/*Q6.3*/
/*
En décidant que Lou est le Max et Tom le min, détermine dès le début de quel côté ils seront respectivement.
Cela supprime toutes les solutions potentielles symmetriques selon le centre de la balançoire.
*/

/*Q6.4*/
vecAbs(Vector, Abs):-
	dim(Vector, [Dim]),
	dim(Abs, [Dim]),
	(for(Ind, 1, Dim),
	param(Vector, Abs)
	do
		Elt is Vector[Ind],
		(Elt #> 0) => Abs[Ind] #= Elt,
		(Elt #=< 0) => Abs[Ind] #= -Elt
	).

/* Test
vecAbs([](1,0,-2),X).

X = [](1, 0, 2)
Yes (0.00s cpu)
*/

sommeMoments(S, P, Res):-
	vecAbs(S, SAbs),
	vecDotProduct(SAbs, P, Res).

/* Test
sommeMoments([](0,1,-4),[](-2,-3,7),X).

X = 25
Yes (0.00s cpu)
*/

solve2(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	ic:labeling(Sieges).
/* Test
minimize(solve2(S, SommeMoments), SommeMoments).
Found a solution with cost 2914
Found a solution with cost 2858
Found a solution with cost 2808
Found a solution with cost 2722
Found a solution with cost 2716
Found a solution with cost 2708
Found a solution with cost 2694
Found a solution with cost 2602
Found a solution with cost 2594
Found a solution with cost 2524
Found a solution with cost 2474
Found a solution with cost 2430
Found a solution with cost 2392
Found a solution with cost 2344
Found a solution with cost 2296
Found a solution with cost 2218
Found a solution with cost 2196
Found a solution with cost 2154
Found a solution with cost 2142
Found a solution with cost 2064
Found a solution with cost 1958
Found a solution with cost 1890
Found a solution with cost 1748
Found a solution with cost 1744
Found a solution with cost 1704
Found a solution with cost 1604
Found no solution with cost -1.0Inf .. 1603

S = [](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
SommeMoments = 1604
Yes (2.92s cpu)
*/

/*Version1*/
solve3(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	search(Sieges, 0, occurence, indomain, complete, []).

/*Test
minimize(solve3(S, SommeMoments), SommeMoments).
Found a solution with cost 1890
Found a solution with cost 1604
Found no solution with cost -1.0Inf .. 1603

S = [](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
SommeMoments = 1604
Yes (1.10s cpu)

On va plus vite
*/


/*Version 2*/
solve4(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	search(Sieges, 0, input_order, indomain_split, complete, []).

/*Test
minimize(solve4(S, SommeMoments), SommeMoments).
Found a solution with cost 2914
Found a solution with cost 2858
Found a solution with cost 2808
Found a solution with cost 2722
Found a solution with cost 2716
Found a solution with cost 2708
Found a solution with cost 2694
Found a solution with cost 2602
Found a solution with cost 2594
Found a solution with cost 2524
Found a solution with cost 2474
Found a solution with cost 2430
Found a solution with cost 2392
Found a solution with cost 2344
Found a solution with cost 2296
Found a solution with cost 2218
Found a solution with cost 2196
Found a solution with cost 2154
Found a solution with cost 2142
Found a solution with cost 2064
Found a solution with cost 1958
Found a solution with cost 1890
Found a solution with cost 1748
Found a solution with cost 1744
Found a solution with cost 1704
Found a solution with cost 1604
Found no solution with cost -1.0Inf .. 1603

S = [](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
SommeMoments = 1604
Yes (1.85s cpu)

On va plus vite que labeling mais pas plus vite que occurence
*/


/*Version 3*/
solve5(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	search(Sieges, 0, occurence, indomain_split, complete, []).
 
 /* Test
minimize(solve5(S, SommeMoments), SommeMoments).
Found a solution with cost 1890
Found a solution with cost 1604
Found no solution with cost -1.0Inf .. 1603

S = [](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
SommeMoments = 1604
Yes (0.69s cpu)
*/

/*Version 4*/
ordrePoids(Sieges, Res):-
	dim(Sieges, [Dim]),
	dim(Res, [Dim]),	
	Luc is Sieges[5],
	Res[1] #= Luc,
	Tom is Sieges[8],
	Res[2] #= Tom,
	Jim is Sieges[3],
	Res[3] #= Jim,
	Lou is Sieges[4],
	Res[4] #= Lou,
	Zoe is Sieges[2],
	Res[5] #= Zoe,
	Ted is Sieges[7],
	Res[6] #= Ted,
	Ron is Sieges[1],
	Res[7] #= Ron,
	Kim is Sieges[10],
	Res[8] #= Kim,
	Max is Sieges[9],
	Res[9] #= Max,
	Dan is Sieges[6],
	Res[10] #= Dan.

solve6(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	ordrePoids(Sieges,Ordre),
	search(Ordre, 0, occurence, indomain_split, complete, []).
 
/*Test
minimize(solve6(S, SommeMoments), SommeMoments).
Found a solution with cost 2426
Found a solution with cost 2354
Found a solution with cost 2326
Found a solution with cost 2324
Found a solution with cost 2262
Found a solution with cost 2204
Found a solution with cost 2132
Found a solution with cost 2038
Found a solution with cost 2006
Found a solution with cost 1912
Found a solution with cost 1890
Found a solution with cost 1880
Found a solution with cost 1696
Found a solution with cost 1604
Found no solution with cost -1.0Inf .. 1603

S = [](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
SommeMoments = 1604
Yes (0.61s cpu)

On va encore plus vite
*/

/* Bonus*/
parentsAuBout2(S):-
	Lou is S[4],
	Tom is S[8],
	ic:max(S, Lou),
	ic:min(S, Tom),
	Lou #>4,
	Tom #<(-4).

constraints2(S, P):-
	equilibre(S, P),
	parentsAuBout2(S),
	enfantsAvecParents(S),
	alldifferent(S).

solve7(Sieges,SommeMoments):-
	poids(Poids),
	sieges(Sieges),
	constraints2(Sieges, Poids),
	sommeMoments(Sieges, Poids, SommeMoments),
	ordrePoids(Sieges,Ordre),
	search(Ordre, 0, occurence, indomain_split, complete, []).

/* Test 
minimize(solve7(S, SommeMoments), SommeMoments).
Found a solution with cost 2454
Found a solution with cost 2428
Found a solution with cost 2426
Found a solution with cost 2328
Found a solution with cost 2270
Found a solution with cost 2222
Found a solution with cost 2180
Found a solution with cost 2176
Found a solution with cost 2172
Found a solution with cost 1940
Found a solution with cost 1912
Found a solution with cost 1890
Found a solution with cost 1856
Found a solution with cost 1828
Found a solution with cost 1672
Found a solution with cost 1666
Found a solution with cost 1604
Found a solution with cost 1506
Found no solution with cost -1.0Inf .. 1505

S = [](3, -2, 1, 7, -1, -3, 2, -4, 6, 5)
SommeMoments = 1506
Yes (0.57s cpu)

On gagne un tout petit peu de temps
*/