%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Apr 2018 09:52
%%%-------------------------------------------------------------------
-module(qsort).
-author("fudalinm").

%% API
-export([lessThan/2,grtEqThan/2,qs/1,randomElems/3,compareSpeed/3]).



lessThan([],_) -> [];
lessThan(L,X) -> [ M || M <- L , M < X].

grtEqThan([],_) -> [];
grtEqThan(L,X) -> [ M || M <- L , M >= X].

qs([]) -> [];
qs([H|T]) -> qs( lessThan(T,H) ) ++ [H] ++ qs( grtEqThan(T,H) ) .


randomElems(N,Min,Max) -> [ (  ( rand:uniform(M)  rem (Max-Min) ) + Min )|| M <- lists:seq(1,N) ].


compareSpeed(L,Fun1,Fun2) -> io:format("qsort nam zwrocil: ~w lists sort wyrzuca nam: ~w~n", [element(1 , timer:tc(Fun1,[L]) ) , element(1 , timer:tc(Fun2,[L]) ) ] ).


%6> lists:foldl(fun(X,Sum) -> list_to_integer([X]) + Sum  end ,0,integer_to_list(123456)).
%7> lists:filter(fun(X) -> (X rem 3 == 0) end , lists:seq(1,1000000) ).






