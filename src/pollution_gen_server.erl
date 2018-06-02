%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Apr 2018 12:02
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("fudalinm").
-behaviour(gen_server).

%dziala trzeba dokonczyc...

%% API
-export([start_link/1, read/0,handle_call/3,stop/0,addStation/1,handle_cast/2,addValue/1,getOneValue/1,getStationMean/1,init/1,terminate/2
        ,removeValue/1,getDailyMean/1, getAirQualityIndex/1,crash/0,init/1,code_change/3,handle_info/2]).

-define(serv, ?MODULE).

init(Init) -> {ok,Init}.

start_link(Init) ->
  IV2 = pollution:createMonitor(),
  gen_server:start_link({local,?serv},?MODULE,IV2,[Init])
.
%jaka wartosc startowa
%do start link dodac wartosc jako argument z ktorym bedzie to wywolywac

%%interfejs %%

%%calls
read() -> gen_server:call(?serv,read)
.
stop() -> gen_server:call(?serv,terminate)
.
getStationMean({Type,NameOrCoordinates}) -> gen_server:call(?serv,{getStationMean,Type,NameOrCoordinates})
.
getDailyMean({Type,Date}) -> gen_server:call(?serv,{getDailyMean,Type,Date})
.
getAirQualityIndex({Date,NameOrCoordinates}) -> gen_server:call(?serv,{getAirQualityIndex,Date,NameOrCoordinates})
.

%%end calls

%casts
addStation({Station,Cords}) -> gen_server:cast(?serv,{addStation,Station,Cords})
.
addValue({NameOrCoordinates,Date,MeasurementType,MeasurementValue}) ->
  gen_server:cast(?serv,{addValue,NameOrCoordinates,Date,MeasurementType,MeasurementValue})
.
getOneValue({Type,Date,NameOrCoordinates}) -> gen_server:cast(?serv,{getOneValue,Type,Date,NameOrCoordinates})
.
removeValue( {Type,Date,NameOrCoordinates} ) -> gen_server:cast(?serv,{removeValue,Type,Date,NameOrCoordinates} )
.
crash() -> gen_server:cast(?serv,{crash}).

%%handle casts%%
handle_cast( {addStation,Station,Cords} , N ) -> {noreply,pollution:addStation(N,Station,Cords)};
handle_cast( {addValue,NameOrCoordinates,Date,MeasurementType,MeasurementValue} , N )  ->
  {noreply,pollution:addValue(N,NameOrCoordinates,Date,MeasurementType,MeasurementValue)};
handle_cast( {removeValue,Type,Date,NameOrCoordinates} , N) -> {noreply,pollution:removeValue(N,Type,Date,NameOrCoordinates)};
handle_cast({crash} , N) -> 20 = 10, {noreply,N}
.
%%end handle casts%%

%%handle calls%%

handle_call(read,_From,N) -> {reply,N,N};
handle_call(terminate,_From,N) -> {stop,normal,ok,N};
handle_call({getStationMean,Type,NameOrCoordinates} ,_From , N ) -> {reply,pollution:getStationMean(N,Type,NameOrCoordinates),N};
handle_call({getOneValue,Type,Date,NameOrCoordinates} , _From , N ) -> {reply,pollution:getOneValue(N,Type,Date,NameOrCoordinates),N};
handle_call({getDailyMean,Type,Date}, _From, N) -> {reply,pollution:getDailyMean(N,Type,Date) , N};
handle_call({getAirQualityIndex,Date,NameOrCoordinates} , _From, N) -> {reply, pollution:getAirQualityIndex(N,Date,NameOrCoordinates) , N}
.

%%end handle calls%%

terminate(normal, _) ->  ok.





handle_info(_Info, State) ->
  {noreply, State}.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.








