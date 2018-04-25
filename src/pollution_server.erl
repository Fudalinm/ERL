%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2018 18:19
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("fudalinm").

%% API
-export([start/0,stop/0,init/0]).
-export([addStation/2,addValue/4,removeValue/3,getAirQualityIndex/2,getStationMean/2,getOneValue/3,getDailyMean/2]).

start() ->
  register( server ,  spawn(?MODULE , init , [])  )
.


stop () ->
  server ! stop
.

init() ->
  M = pollution:createMonitor(),
  loop (M)
  .

loop(Monitor) ->
  receive
    stop -> ok;
    {PID,addStation,StationName,Coordinates} -> %ok
      UM = pollution:addStation(Monitor,StationName,Coordinates),
      PID ! UM,
      loop(UM);

    {PID,addValue,NameOrCoordinates,Date,MeasurementType,MeasurementValue} -> %ok
      UM = pollution:addValue(Monitor,NameOrCoordinates,Date,MeasurementType,MeasurementValue),
      PID ! UM,
      loop(UM);

    {PID,removeValue,Type,Date,NameOrCoordinates} -> %ok
      UM = pollution:removeValue(Monitor,Type,Date,NameOrCoordinates),
      PID ! UM,
      loop(UM);

    {PID,getDailyMean,Type,Date} -> %ok
      XD = pollution:getDailyMean(Monitor,Type,Date),
      PID ! XD,
      io:format(XD),
      loop(Monitor);

    {PID,getOneValue,Type,Date,NameOrCoordinates} -> %ok
      XD = pollution:getOneValue(Monitor,Type,Date,NameOrCoordinates),
      PID ! XD,
      io:format(XD),
      loop(Monitor);

    {PID,getStationMean,Type,NameOrCoordinates} -> %ok
      XD = pollution:getStationMean(Monitor,Type,NameOrCoordinates),
      PID ! XD,
      io:format(XD),
      loop(Monitor);


    {PID,getAirQualityIndex,Date,NameOrCoordinates} -> %ok
      XD = pollution:getAirQualityIndex(Monitor,Date,NameOrCoordinates),
      PID ! XD,
      io:format(XD),
      loop(Monitor)

end.

addStation(StationName,Coordinates) ->
  server ! {self(),addStation,StationName,Coordinates},
  receive
    M -> io:format("Result: ~p~n", [M])
  end.
%tu cos trzeba odebrac
addValue(NameOrCoordinates,Date,MeasurementType,MeasurementValue) ->
  server ! {self(),addValue,NameOrCoordinates,Date,MeasurementType,MeasurementValue}
.
removeValue(Type,Date,NameOrCoordinates) ->
  server ! {self(),removeValue,Type,Date,NameOrCoordinates}
.
getDailyMean(Type,Date) ->
  server ! {self(),getDailyMean,Type,Date}
.
getOneValue(Type,Date,NameOrCoordinates) ->
  server ! {self(),getOneValue,Type,Date,NameOrCoordinates}
.
getStationMean(Type,NameOrCoordinates) ->
  server ! {self(),getStationMean,Type,NameOrCoordinates}
.
getAirQualityIndex(Date,NameOrCoordinates) ->
  server ! {self(),getAirQualityIndex,Date,NameOrCoordinates}
.






