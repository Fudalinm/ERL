%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Apr 2018 11:31
%%%-------------------------------------------------------------------
-module(pollution_sup).
-author("fudalinm").

%% API
-export([init/0,loop/0,start/0]).

start() ->
  spawn_link(?MODULE,init,[])
  .


init() ->
  process_flag(trap_exit,true),
  loop()
  .

%potrzebujemy jeszcze funkcje start ktor bedzie starotwala nadzworce
loop() ->
  pollution_server:start(),
  receive
    {'EXIT',Pid,Reason}  -> loop()
  end
.