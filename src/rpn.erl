%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Apr 2018 09:15
%%%-------------------------------------------------------------------
-module(rpn).
-author("fudalinm").

%% API
-export([rpn/1]).


rpn (M) when is_list(M) ->
  Out = lists:foldl(fun rpn/2,[], string:tokens(M," ")),
  Out.

%pobiera nowy element z listy i akumulator i zwraca wartosc do akumulatora

rpn("+", [N1,N2|S]  ) -> [N2+N1|S];                   %jak trafiamy na operacje z 2 elementmi to wykonujemy na 2 pierwszych z aku
rpn("-", [N1,N2|S]  ) -> [N2-N1|S];
rpn("*", [N1,N2|S]  ) -> [N2*N1|S];
rpn("/", [N1,N2|S]  ) -> [N2/N1|S];
rpn("^", [N1,N2|S]  ) -> [math:pow(N2,N1)|S];
rpn("ln",    [N|S]  ) -> [math:log(float(N))|S];             %pojedyncza funkcje ewaluujemy odrazu i zwracamy ja do akumulatora
rpn("log10", [N|S]  ) -> [math:log10(float(N))|S];          %rzutujemy na floata bo funcje nie dzialaja z integerami
rpn("sin",   [N|S]  ) -> [math:sin(float(N))|S];
rpn("cos",   [N|S]  ) -> [math:cos(float(N))|S];
rpn("tg",    [N|S]  ) -> [math:sin(float(N))/math:cos(float(N))|S]; %dopiero potem znalazlem odpowiednie funkcje tan i tanh
rpn("ctg",   [N|S]  ) -> [math:cos(float(N))/math:sin(float(N))|S];
rpn("sqrt",  [N|S]  ) -> [math:sqrt(float(N))|S];
rpn(X, Stack) -> [read(X)|Stack].                      % przypadek gdy nie bylo nic w akumulatorze wiec dodajemy do niego

%sqrt i  trygonometryczne

%probujemy zrzutowac na floata jak nie wychodzi do na inta ja wyszlo to go zwracamy
read(N) ->
  case string:to_float(N) of
    {error,no_float} -> list_to_integer(N);   %jezeli nie float to rzutujemy na integera
    {F,_} -> F                                %w pierwsym zwraca floata w drugim reszte stringa...
  end.