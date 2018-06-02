%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. May 2018 17:27
%%%-------------------------------------------------------------------
-module(pollution_gs_sup).
-author("fudalinm").
-behavior(supervisor).


%% API
-export([start_link/0,init/1]).



start_link() ->
  supervisor:start_link({local, supervisor}, ?MODULE, []).



%%%


init(InitValue) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 1000,
  MaxSecondsBetweenRestarts = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  AChild = {pollution_gen_server, {pollution_gen_server, start_link, [InitValue]},
    Restart, Shutdown, Type, [pollution_gen_server]},

  {ok, {SupFlags, [AChild]}}
.

