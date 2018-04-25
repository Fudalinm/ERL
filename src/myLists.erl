%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Mar 2018 18:18
%%%-------------------------------------------------------------------
-module(myLists).
-author("fudalinm").

%% API
-export([power/2,contains/2,duplicate/1,kart1/1,lessThan/2,lessThan2/2,maping/2,drzewo/0,typdrzewa/0]).


%recordy

-record(drzewo,{wysokosc,liscie,kolorLisci = 'Niebieski'}).
-record(typdrzewa,{typ = 'jablkowe', drzewo}).

drzewo() ->
  Drzewo1 = #drzewo{wysokosc = 10,liscie = 20},
  Drzewo2 = #drzewo{wysokosc = 5,liscie = 40, kolorLisci = 'yolo'},
  Drzewo3 = Drzewo1#drzewo{kolorLisci = 'zolty'},

  io:format(Drzewo1#drzewo.kolorLisci),
  io:format(Drzewo2#drzewo.kolorLisci),
  io:format(Drzewo3#drzewo.kolorLisci).

typdrzewa() ->
  Typ1 = #typdrzewa{typ = 'gruszkowe',drzewo = #drzewo{wysokosc = 10,kolorLisci = 'jakis'}},
  io:format(Typ1#typdrzewa.typ),
  io:format(Typ1#typdrzewa.drzewo#drzewo.kolorLisci).

%3> Str
%.
%{a,b,c}
%4> element(2,Str).

power (M,N) ->
      if
        N == 0 -> 1;
        N > 0 -> M * power(M,N-1);
        N < 0 -> 1/M * power(M,N+1)
      end.

contains (_,[]) -> false;
contains (M , [H | T]) -> (H == M) or contains(M,T).

duplicate ([]) -> [];
duplicate ([H | T]) -> [ H , H ] ++ duplicate(T).

kart1(M) -> if
              (is_integer(M)) and (M rem 7 == 0) and (M rem 3 == 0) -> true;
              true -> false
            end.
%lab2

lessThan([],_) -> [];
lessThan([H|T],X) -> if
                        X =< H ->  lessThan(T,X);
                        true -> [H] ++ lessThan(T,X)
                      end .

lessThan2([],_) -> [];
lessThan2(L,X) -> [M || M <- L , M < X] . %PODWOJNY PIPE!!!!!!



maping ([],_) -> [];
maping ([H | T] , F) -> F(H) ++ maping(T,F).

%%lab2











