%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Apr 2018 09:52
%%%-------------------------------------------------------------------
-module(pollution).
-author("fudalinm").

%% API
-export([createMonitor/0,addStation/3,addValue/5,getOneValue/4,removeValue/4,getStationMean/3,getDailyMean/3,getAirQualityIndex/3,
  getTypeMeasurement/3,getMeasurement/4,getStationId/2,signValues/1,
  debug1/1,debug2/3]).

%odczyty w rekordach
-record(monitor,{cToId,nToId,idToSt,nextId = 0}). %stations w postaci listy
-record(station,{stationName,coordinates,measurements = []}). %coordinates {X,Y} mapa data na pomiary?
-record(measurement,{type,date,value}). %data przechowywana jest w kluczu mapy

%nie dzalajaca! getAirQualityIndex

%dziala
createMonitor () ->
  #monitor{
    cToId = #{}, %wskazuje koordynaty na id
    nToId = #{} , %wskazuje nazwe na id
    idToSt = #{}    %wskazuje id na stacje
  }
.

%kluczem pomiaru jest data a wartoscia jest lista/mapa pomiarow
addStation(Monitor,StationName,Coordinates) ->
  case{maps:is_key(StationName,Monitor#monitor.nToId) , maps:is_key(Coordinates,Monitor#monitor.cToId)} of
    {false,false} ->
      StationToAdd = #station{
        stationName = StationName,
        coordinates = Coordinates,
        measurements = []
      },
      Id = Monitor#monitor.nextId ,
      Monitor#monitor{
        cToId  = maps:put(Coordinates,Id,Monitor#monitor.cToId),
        nToId  = maps:put(StationName,Id,Monitor#monitor.nToId),
        idToSt = maps:put(Id,StationToAdd,Monitor#monitor.idToSt),
        nextId = Id + 1
      };
    {_,_} -> Monitor
  end
.

%dziala
%addValue/5 - dodaje odczyt ze stacji (współrzędne geograficzne lub(albo) nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Monitor,NameOrCoordinates,Date,MeasurementType,MeasurementValue) ->
  %musimy dostac nasza stacje
  Id = getStationId(NameOrCoordinates,Monitor),
  Station = maps:get(Id,Monitor#monitor.idToSt),
  Measurements = getMeasurement(Monitor,MeasurementType,Date,NameOrCoordinates),
  case Measurements of
      %tu dodajemy
      [] ->
        MeasurementToAdd = #measurement{
          type = MeasurementType,
          date = Date,
          value = MeasurementValue
        },
        NewStation = #station{
          stationName = Station#station.stationName,
          coordinates = Station#station.coordinates,
          measurements = lists:append(Station#station.measurements,[MeasurementToAdd])
        },
        Tmp = maps:put(Id,NewStation,Monitor#monitor.idToSt), %put czy update jaka jest miedzy nim roznica...?
        Monitor#monitor{
          cToId  = Monitor#monitor.cToId,
          nToId  = Monitor#monitor.nToId,
          idToSt = Tmp,
          nextId = Monitor#monitor.nextId
        }
      ;
      %tu zwracamy monitor
      _ -> Monitor
end
.

%działa!!!
%removeValue/4 - usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru), zwraca zaktualizowany monitor;
removeValue(Monitor,Type,Date,NameOrCoordinates) ->
  Id = getStationId(NameOrCoordinates,Monitor),
  Station = maps:get(Id,Monitor#monitor.idToSt),
  [Measurement | _] = getMeasurement(Monitor,Type,Date,NameOrCoordinates),
  NewList = lists:delete(Measurement,Station#station.measurements),
  NewStation = #station{
    stationName = Station#station.stationName,
    coordinates = Station#station.coordinates,
    measurements = NewList
  },
  Tmp = maps:put(Id,NewStation,Monitor#monitor.idToSt),
  Monitor#monitor{
    cToId  = Monitor#monitor.cToId,
    nToId  = Monitor#monitor.nToId,
    idToSt = Tmp,
    nextId = Monitor#monitor.nextId
  }
.

%to dziala
debug1 (Monitor) ->
   [ maps:get(Id,Monitor#monitor.idToSt)
    ||
    Id <- lists:seq(0,Monitor#monitor.nextId - 1)  ].

%to nie dziala a jednak po poprawkach zadzialalo
debug2 (Type,Date,Stations) ->
    [Station#station.measurements#measurement.value
    ||
    Station <- Stations,
    Station#station.measurements#measurement.type == Type,
    Station#station.measurements#measurement.date == Date ]
.

%NO dziala po dniu!!
%getDailyMean/3 - zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Monitor,Type,Date) ->
  Stations = [ maps:get(Id,Monitor#monitor.idToSt)
    ||
    Id <- lists:seq(0,Monitor#monitor.nextId - 1)  ],
  %to nie dziala
  Values = [Measurement2#measurement.value
    ||
    Station <- Stations,
    %tu dostal liste i teraz on ja glupio porownuje
    Measurement2 <- Station#station.measurements,
    Measurement2#measurement.type == Type,
    element(1,Measurement2#measurement.date) == element(1,Date)],
  case length(Values) of
    0 -> -1;
    _ -> (lists:foldl(fun(X,Y) -> X + Y end, 0 , Values) / length(Values))
  end
.

%dziala
%jak brak to pusta lista w pp element
%getOneValue/4 - zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Monitor,Type,Date,NameOrCoordinates) ->
  Measurement = getMeasurement(Monitor,Type,Date,NameOrCoordinates),
  case  Measurement of
    [] ->  [];
    [H | _]  -> H#measurement.value
  end
.

%dziala!!!!!!
%getStationMean/3 - zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean(Monitor,Type,NameOrCoordinates) ->
  Measurements = getTypeMeasurement(Monitor,Type,NameOrCoordinates),
  Values = signValues(Measurements),
  case length(Values) of
    0 -> -1;
    _ -> ( lists:foldl(fun(X,Y) -> X + Y end, 0 ,Values ) / (length(Values)) )
  end
.

%tez musi dzialac
signValues(Measurements) ->
  case Measurements of
    [] -> [];
    [H | T] -> [H#measurement.value ] ++ signValues(T)
  end
.

%działa
%pomocnicza pobiera nam id stacji znajac jej coordy albo nazwe
getStationId(NameOrCoordinates,Monitor) ->
  case NameOrCoordinates of
    {_,_} -> maps:get(NameOrCoordinates,Monitor#monitor.cToId);
    _     -> maps:get(NameOrCoordinates,Monitor#monitor.nToId)
  end
.

%dziala
getMeasurement (Monitor,Type,Date,NameOrCoordinates) ->
  Id = getStationId(NameOrCoordinates,Monitor),
  Station = maps:get(Id,Monitor#monitor.idToSt),
  %to powinno nam zwrocic jednoelemntowa liste albo pusta
  [ X || X <- Station#station.measurements , X#measurement.type == Type , X#measurement.date == Date]
.

%dziala!!!
getTypeMeasurement (Monitor,Type,NameOrCoordinates) ->
  Id = getStationId(NameOrCoordinates,Monitor),
  Station = maps:get(Id,Monitor#monitor.idToSt),
  %to powinno nam zwrocic liste typow pomiarow
  [ X || X <- Station#station.measurements , X#measurement.type == Type]
.

%niespodzinka(
%indeks jakosci powietrza dostaje koordynaty(tak naprawde) , date i monitor

getAirQualityIndex(Monitor,Date,NameOrCoordinates) ->
  %norma to odpowiednio 50 i 30
  X = getMeasurement(Monitor,"PM10",Date,NameOrCoordinates),
  Y = getMeasurement(Monitor,"PM2,5",Date,NameOrCoordinates),
  if
    ( (length(X) == 0 ) and (length(Y) == 0 )) -> -1;
    length(Y) == 0 -> [PM10 | _] = X, PM10#measurement.value/50;
    length(X) == 0 -> [PM25 | _] = Y, PM25#measurement.value/30;
    true -> [PM10 | _] = X, [PM25 | _] = Y, max(PM10#measurement.value/50,PM25#measurement.value/30)
  end
.