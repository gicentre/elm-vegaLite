port module Walkthrough exposing (elmToJS)

import Platform
import VegaLite exposing (..)


path : String
path =
    "https://cdn.jsdelivr.net/npm/vega-datasets@2.2/data/"


cfg =
    configure
        << configuration (coView [ vicoStroke Nothing ])
        << configuration (coBackground "rgba(0,0,0,0)")


stripPlot : Spec
stripPlot =
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , tick []
        , encoding (position X [ pName "temp_max", pQuant ] [])
        ]


histogram : Spec
histogram =
    let
        enc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , bar []
        , enc []
        ]


stackedHistogram : Spec
stackedHistogram =
    let
        enc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
                << color [ mName "weather" ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , bar []
        , enc []
        ]


weatherColors : List ScaleProperty
weatherColors =
    categoricalDomainMap
        [ ( "sun", "#e7ba52" )
        , ( "fog", "#c7c7c7" )
        , ( "drizzle", "#aec7ea" )
        , ( "rain", "#1f77b4" )
        , ( "snow", "#9467bd" )
        ]


stackedHistogram2 : Spec
stackedHistogram2 =
    let
        enc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
                << color [ mName "weather", mScale weatherColors ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , bar []
        , enc []
        ]


lineChart : Spec
lineChart =
    let
        enc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
                << color [ mName "weather", mScale weatherColors ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , line []
        , enc []
        ]


multiBar : Spec
multiBar =
    let
        enc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
                << color [ mName "weather", mLegend [], mScale weatherColors ]
                << column [ fName "weather" ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , bar []
        , enc []
        ]


barChart : Spec
barChart =
    let
        enc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pName "precipitation", pAggregate opMean ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , bar []
        , enc []
        ]


barChartWithAverage : Spec
barChartWithAverage =
    let
        precipEnc =
            encoding
                << position Y [ pName "precipitation", pAggregate opMean ]

        barEnc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , precipEnc []
        , layer [ asSpec [ bar [], barEnc [] ], asSpec [ rule [] ] ]
        ]


barChartPair : Spec
barChartPair =
    let
        bar1Enc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pName "precipitation", pAggregate opMean ]

        bar2Enc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pName "temp_max", pAggregate opMean ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , vConcat [ asSpec [ bar [], bar1Enc [] ], asSpec [ bar [], bar2Enc [] ] ]
        ]


barChartTriplet : Spec
barChartTriplet =
    let
        enc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pRepeat arRow, pAggregate opMean ]

        spec =
            asSpec
                [ dataFromUrl (path ++ "seattle-weather.csv") []
                , bar []
                , enc []
                ]
    in
    toVegaLite
        [ cfg []
        , repeat [ rowFields [ "precipitation", "temp_max", "wind" ] ]
        , specification spec
        ]


splom : Spec
splom =
    let
        enc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pRepeat arRow, pQuant ]

        spec =
            asSpec
                [ dataFromUrl (path ++ "seattle-weather.csv") []
                , point []
                , enc []
                ]
    in
    toVegaLite
        [ cfg []
        , repeat
            [ rowFields [ "temp_max", "precipitation", "wind" ]
            , columnFields [ "wind", "precipitation", "temp_max" ]
            ]
        , specification spec
        ]


dashboard1 : Spec
dashboard1 =
    let
        histoEnc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]

        histoSpec =
            asSpec [ title "Frequency histogram" [], bar [], histoEnc [] ]

        scatterEnc =
            encoding
                << position X [ pName "temp_max", pQuant ]
                << position Y [ pName "precipitation", pQuant ]

        scatterSpec =
            asSpec [ title "Scatterplot" [], point [], scatterEnc [] ]

        barEnc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pName "precipitation", pAggregate opMean ]

        barSpec =
            asSpec [ title "Bar chart" [], bar [], barEnc [] ]

        annotationEnc =
            encoding
                << position Y
                    [ pName "precipitation"
                    , pAggregate opMean
                    , pScale [ scDomain (doNums [ 0, 5.5 ]) ]
                    ]

        annotationSpec =
            asSpec [ title "Annotation" [], width 200, rule [], annotationEnc [] ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "seattle-weather.csv") []
        , hConcat [ histoSpec, scatterSpec, barSpec, annotationSpec ]
        ]


dashboard2 : Spec
dashboard2 =
    let
        histoEnc =
            encoding
                << position X [ pName "temp_max", pBin [] ]
                << position Y [ pAggregate opCount ]
                << color [ mName "weather", mLegend [], mScale weatherColors ]
                << column [ fName "weather" ]

        histoSpec =
            asSpec [ bar [], histoEnc [] ]

        scatterEnc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pRepeat arRow, pQuant ]

        scatterSpec =
            asSpec [ point [], scatterEnc [] ]

        barEnc =
            encoding
                << position X [ pName "date", pOrdinal, pTimeUnit month ]
                << position Y [ pRepeat arRow, pAggregate opMean ]

        annotationEnc =
            encoding
                << position Y [ pRepeat arRow, pAggregate opMean ]

        layerSpec =
            asSpec
                [ layer
                    [ asSpec [ bar [], barEnc [] ]
                    , asSpec [ rule [], annotationEnc [] ]
                    ]
                ]

        barsSpec =
            asSpec
                [ repeat [ rowFields [ "precipitation", "temp_max", "wind" ] ]
                , specification layerSpec
                ]

        splomSpec =
            asSpec
                [ repeat
                    [ rowFields [ "temp_max", "precipitation", "wind" ]
                    , columnFields [ "wind", "precipitation", "temp_max" ]
                    ]
                , specification scatterSpec
                ]
    in
    toVegaLite
        [ cfg []
        , --   dataFromUrl (path ++ "newYork-weather.csv") []
          dataFromUrl (path ++ "seattle-weather.csv") []
        , vConcat
            [ asSpec [ hConcat [ splomSpec, barsSpec ] ]
            , histoSpec
            ]
        ]


scatterProps : List ( VLProperty, Spec )
scatterProps =
    let
        trans =
            -- This rounds the year-month-day format to just year for later selection.
            transform
                << calculateAs "year(datum.Year)" "Year"

        enc =
            encoding
                << position X [ pName "Horsepower", pQuant ]
                << position Y [ pName "Miles_per_Gallon", pQuant ]
                << color [ mCondition (prParam "picked") [ mName "Origin" ] [ mStr "grey" ] ]
    in
    [ cfg []
    , dataFromUrl (path ++ "cars.json") []
    , trans []
    , circle []
    , enc []
    ]


interactiveScatter1 : Spec
interactiveScatter1 =
    let
        ps =
            params
                << param "picked" [ paSelect sePoint [ seToggle tpFalse ] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter2 : Spec
interactiveScatter2 =
    let
        ps =
            params
                << param "picked" [ paSelect sePoint [] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter3 : Spec
interactiveScatter3 =
    let
        ps =
            params
                << param "picked" [ paSelect sePoint [ seOn "mouseover" ] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter4 : Spec
interactiveScatter4 =
    let
        ps =
            params
                << param "picked" [ paSelect sePoint [ seFields [ "Cylinders" ] ] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter5 : Spec
interactiveScatter5 =
    let
        ps =
            params
                << param "picked"
                    [ paSelect sePoint [ seFields [ "Cylinders" ] ]
                    , paBind (ipRange [ inMin 3, inMax 8, inStep 1 ])
                    ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter6 : Spec
interactiveScatter6 =
    let
        ps =
            params
                << param "picked"
                    [ paSelect sePoint [ seFields [ "Cylinders", "Year" ] ]
                    , paBindings
                        [ ( "Cylinders", ipRange [ inMin 3, inMax 8, inStep 1 ] )
                        , ( "Year", ipRange [ inMin 1969, inMax 1981, inStep 1 ] )
                        ]
                    ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter7 : Spec
interactiveScatter7 =
    let
        ps =
            params
                << param "picked" [ paSelect seInterval [] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter8 : Spec
interactiveScatter8 =
    let
        ps =
            params
                << param "picked" [ paSelect seInterval [ seEncodings [ chX ] ] ]
    in
    toVegaLite (ps [] :: scatterProps)


interactiveScatter9 : Spec
interactiveScatter9 =
    let
        ps =
            params
                << param "picked"
                    [ paSelect seInterval [ seEncodings [ chX ] ]
                    , paBindScales
                    ]
    in
    toVegaLite (ps [] :: scatterProps)


coordinatedScatter1 : Spec
coordinatedScatter1 =
    let
        ps =
            params
                << param "picked" [ paSelect seInterval [ seEncodings [ chX ] ] ]

        enc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pRepeat arRow, pQuant ]
                << color [ mCondition (prParam "picked") [ mName "Origin" ] [ mStr "grey" ] ]

        spec =
            asSpec [ dataFromUrl (path ++ "cars.json") [], ps [], enc [], circle [] ]
    in
    toVegaLite
        [ cfg []
        , repeat
            [ rowFields [ "Displacement", "Miles_per_Gallon" ]
            , columnFields [ "Horsepower", "Miles_per_Gallon" ]
            ]
        , specification spec
        ]


coordinatedScatter2 : Spec
coordinatedScatter2 =
    let
        ps =
            params
                << param "picked" [ paSelect seInterval [], paBindScales ]

        enc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pRepeat arRow, pQuant ]
                << color [ mName "Origin" ]

        spec =
            asSpec
                [ dataFromUrl (path ++ "cars.json") [], ps [], enc [], circle [] ]
    in
    toVegaLite
        [ cfg []
        , repeat
            [ rowFields [ "Displacement", "Miles_per_Gallon" ]
            , columnFields [ "Horsepower", "Miles_per_Gallon" ]
            ]
        , specification spec
        ]


contextAndFocus : Spec
contextAndFocus =
    let
        ps =
            params
                << param "brush" [ paSelect seInterval [ seEncodings [ chX ] ] ]

        encContext =
            encoding
                << position X [ pName "date", pTemporal, pAxis [ axFormat "%Y" ] ]
                << position Y
                    [ pName "price"
                    , pQuant
                    , pAxis [ axTickCount (niTickCount 3), axGrid False ]
                    ]

        specContext =
            asSpec [ width 400, height 80, ps [], encContext [], area [] ]

        encDetail =
            encoding
                << position X
                    [ pName "date"
                    , pTemporal
                    , pScale [ scDomain (doSelection "brush") ]
                    , pTitle ""
                    ]
                << position Y [ pName "price", pQuant ]

        specDetail =
            asSpec [ width 400, encDetail [], area [] ]
    in
    toVegaLite
        [ cfg []
        , dataFromUrl (path ++ "sp500.csv") []
        , vConcat [ specContext, specDetail ]
        ]


crossFilter : Spec
crossFilter =
    let
        hourTrans =
            -- This generates a new field based on the hour of day extracted from the date field.
            transform
                << calculateAs "hours(datum.date)" "hour"

        ps =
            params
                << param "brush" [ paSelect seInterval [ seEncodings [ chX ] ] ]

        filterTrans =
            transform
                << filter (fiSelection "brush")

        totalEnc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pAggregate opCount ]

        selectedEnc =
            encoding
                << position X [ pRepeat arColumn, pQuant ]
                << position Y [ pAggregate opCount ]
                << color [ mStr "goldenrod" ]
    in
    toVegaLite
        [ cfg []
        , repeat [ columnFields [ "hour", "delay", "distance" ] ]
        , specification <|
            asSpec
                [ dataFromUrl (path ++ "flights-2k.json") [ parse [ ( "date", foDate "%Y/%m/%d %H:%M" ) ] ]
                , hourTrans []
                , layer
                    [ asSpec [ totalEnc [], bar [] ]
                    , asSpec [ ps [], filterTrans [], selectedEnc [], bar [] ]
                    ]
                ]
        ]



{- This list comprises tuples of the label for each embedded visualization and
   corresponding Vega-Lite specification.
-}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "singleView1", stripPlot )
        , ( "singleView2", histogram )
        , ( "singleView3", stackedHistogram )
        , ( "singleView4", stackedHistogram2 )
        , ( "singleView5", lineChart )
        , ( "multiView1", multiBar )
        , ( "multiView2", barChart )
        , ( "multiView3", barChartWithAverage )
        , ( "multiView4", barChartPair )
        , ( "multiView5", barChartTriplet )
        , ( "multiView6", splom )
        , ( "dashboard1", dashboard1 )
        , ( "dashboard2", dashboard2 )
        , ( "interactive1", interactiveScatter1 )
        , ( "interactive2", interactiveScatter2 )
        , ( "interactive3", interactiveScatter3 )
        , ( "interactive4", interactiveScatter4 )
        , ( "interactive5", interactiveScatter5 )
        , ( "interactive6", interactiveScatter6 )
        , ( "interactive7", interactiveScatter7 )
        , ( "interactive8", interactiveScatter8 )
        , ( "interactive9", interactiveScatter9 )
        , ( "coordinated1", coordinatedScatter1 )
        , ( "coordinated2", coordinatedScatter2 )
        , ( "coordinated3", contextAndFocus )
        , ( "crossFilter1", crossFilter )
        ]



{- The code below is boilerplate for creating a headless Elm module that opens
   an outgoing port to Javascript and sends the specs to it.
-}


main : Program () Spec msg
main =
    Platform.worker
        { init = always ( mySpecs, elmToJS mySpecs )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


port elmToJS : Spec -> Cmd msg
