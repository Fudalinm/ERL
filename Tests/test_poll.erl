%%%-------------------------------------------------------------------
%%% @author fudalinm
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2018 21:26
%%%-------------------------------------------------------------------
-module(test_poll).
-author("fudalinm").

-include_lib("eunit/include/eunit.hrl").

createMonitor_test()  ->
  ?assertEqual(
    pollution:createMonitor() ,
    {monitor, #{}, #{}, #{} , 0 } )
.

addStation_test()     ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation(P,"ABcd",{54.321,12.34}),
  ?assertEqual ( P1 , {monitor, #{ {54.321,12.34} => 0 } , #{ "ABcd" => 0} , #{0 => {station,"ABcd",{54.321,12.34},[]} } ,1 } ),
  P2 = pollution:addStation(P1,"ABcdee",{5.321,1.34}),
  ?assertEqual ( P2 ,
    {monitor,
      #{ {54.321,12.34} => 0 , {5.321,1.34} => 1 } ,
      #{ "ABcd" => 0 , "ABcdee" => 1} ,
      #{0 => {station,"ABcd",{54.321,12.34},[]} ,
        1 => {station,"ABcdee",{5.321,1.34},[]}  },
      2}
  ) .


addValue_test()       ->
  P = pollution:createMonitor(),
  P1 =  pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addStation(P1,"ABcdee",{5.321,1.34}),
  P3 = pollution:addValue(P2,"ABcdee",{{2018,4,11},{20,15,24}},"PM2,5",113),
  ?assertEqual (P3 ,
    {monitor,#{{5.321,1.34} => 1,{54.321,12.34} => 0},
      #{"ABcd" => 0,"ABcdee" => 1},
      #{0 => {station,"ABcd",{54.321,12.34},[]},
        1 => {station,"ABcdee",
          {5.321,1.34},
          [{measurement,"PM2,5",{{2018,4,11},{20,15,24}},113}]}},
      2}
  ),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),
  ?assertEqual (P4,
    {monitor,#{{5.321,1.34} => 1,{54.321,12.34} => 0},
      #{"ABcd" => 0,"ABcdee" => 1},
      #{0 => {station,"ABcd",
        {54.321,12.34},
        [{measurement,"PM2,5",{{2018,4,11},{20,15,36}},113}]},
        1 => {station,"ABcdee",
          {5.321,1.34},
          [{measurement,"PM2,5",{{2018,4,11},{20,15,24}},113}]}},
      2}
    )
.

removeValue_test()    ->
  P = pollution:createMonitor(),
  P1 =  pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addStation(P1,"ABcdee",{5.321,1.34}),
  P3 = pollution:addValue(P2,"ABcdee",{{2018,4,11},{20,15,24}},"PM2,5",113),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),
  P5 = pollution:removeValue(P4,"PM2,5",{{2018,4,11},{20,15,36}},"ABcd"),
  ?assertEqual(P5,
    {monitor,#{{5.321,1.34} => 1,{54.321,12.34} => 0},
      #{"ABcd" => 0,"ABcdee" => 1},
      #{0 => {station,"ABcd",{54.321,12.34},[]},
        1 => {station,"ABcdee",
          {5.321,1.34},
          [{measurement,"PM2,5",{{2018,4,11},{20,15,24}},113}]}},
      2}
    ),
  P6 = pollution:removeValue(P5,"PM2,5",{{2018,4,11},{20,15,24}},{5.321,1.34}),
  ?assertEqual(P6,
    {monitor,#{{5.321,1.34} => 1,{54.321,12.34} => 0},
      #{"ABcd" => 0,"ABcdee" => 1},
      #{0 => {station,"ABcd",{54.321,12.34},[]},
        1 => {station,"ABcdee",{5.321,1.34},[]}},
      2}
    )
.

getOneValue_test()    ->
  P  = pollution:createMonitor(),
  P1 = pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addStation(P1,"ABcdee",{5.321,1.34}),

  P3 = pollution:addValue(P2,"ABcdee",{{2018,4,11},{20,15,24}},"PM2,5",113),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),

  X  = pollution:getOneValue(P4,"PM2,5",{{2018,4,11},{20,15,36}},"ABcd"),
  ?assertEqual (X , 113),

  Y  = pollution:getOneValue(P4,"PM2,5",{{2018,4,11},{20,15,36}},"ABcd"),
  ?assertEqual (Y, 113)
.

getStationMean_test() ->
  P  = pollution:createMonitor(),
  P1 = pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addValue(P1,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),
  P3 = pollution:addValue(P2,{54.321,12.34},{{2018,4,10},{20,15,36}},"PM2,5",10),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,9},{10,15,36}},"PM2,5",21),
  X = pollution:getStationMean(P4,"PM2,5",{54.321,12.34}),
  Y = pollution:getStationMean(P4,"PM2,5","ABcd"),
  ?assertEqual(X, 48.0),
  ?assertEqual(Y,48.0)
.


getDailyMean_test()   ->
  P  = pollution:createMonitor(),
  P1 = pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addValue(P1,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),
  P3 = pollution:addValue(P2,{54.321,12.34},{{2018,4,11},{20,15,10}},"PM2,5",10),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,9},{10,15,36}},"PM2,5",21),
  X  = pollution:getDailyMean(P4,"PM2,5",{{2018,4,11},{20,15,36}}),
  ?assertEqual(61.5,X)
.

getAirQualityIndex_test() ->
  P  = pollution:createMonitor(),
  P1 = pollution:addStation(P,"ABcd",{54.321,12.34}),
  P2 = pollution:addValue(P1,{54.321,12.34},{{2018,4,11},{20,15,36}},"PM2,5",113),
  P3 = pollution:addValue(P2,{54.321,12.34},{{2018,4,11},{20,15,10}},"PM2,5",10),
  P4 = pollution:addValue(P3,{54.321,12.34},{{2018,4,9},{10,15,36}},"PM2,5",21),
  P5 = pollution:addValue(P4,{54.321,12.34},{{2018,4,9},{10,15,36}},"PM10",121),
  P6 = pollution:addValue(P5,{54.321,12.34},{{2018,4,9},{11,15,36}},"PM10",111),
  X  = pollution:getAirQualityIndex(P6,{{2018,4,9},{10,15,36}},"ABcd"),
  Y  = pollution:getAirQualityIndex(P6,{{2018,4,9},{10,15,36}},{54.321,12.34}),
  ?assertEqual(X,2.42),
  ?assertEqual(Y,2.42)
.