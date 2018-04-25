%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Apr 2018 11:33
%%%-------------------------------------------------------------------

%jak to zrobic!!!!!!


-module(pingpong).
-author("fudalinm").

%% API
-export([ start/0 , stop/0 , play/1 ,ping_loop/0,pong_loop/0 ]).

start()->
  N = 20,
  register(ping, spawn(?MODULE, ping_loop,[] ) ),
  register(pong, spawn(?MODULE, pong_loop,[] ) ),
  play(N)
.


play(N) ->
  ping ! N
.

stop() ->
  ping ! -1,
  pong ! -1
.


ping_loop () ->
  receive
    -1 -> ok;
    0 -> timer:sleep(4),ok;
    N -> io:format("ping~n"), whereis(pong) ! N-1 , ping_loop()
  after
    20000 -> ok
  end.


pong_loop () ->
  receive
    -1 -> ok;
    0 -> timer:sleep(4),ok;
    N -> io:format("pong~n"), whereis(ping) ! N-1, pong_loop()
  after
    20000 -> ok
  end.

