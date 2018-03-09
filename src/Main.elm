module Main exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Sheet
import Task


---- MODEL ----


type alias Model =
    { rows : Int
    , columns : Int
    , selected : Sheet.Position
    , sheet : Sheet.Cells
    }


init : ( Model, Cmd Msg )
init =
    ( { rows = 20
      , columns = 5
      , selected = Sheet.Position 1 1
      , sheet = Sheet.empty
      }
    , focusForumulaInput
    )


formulaInputId : String
formulaInputId =
    "formula-input"


focusForumulaInput : Cmd Msg
focusForumulaInput =
    Dom.focus formulaInputId
        |> Task.attempt (\_ -> NoOp)



---- UPDATE ----


type Msg
    = NoOp
    | SelectCell Sheet.Position
    | InputFormula String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectCell position ->
            ( { model | selected = position }, focusForumulaInput )

        InputFormula input ->
            ( { model | sheet = Sheet.insertFormula model.selected input model.sheet }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        offset =
            "30px"
    in
    main_
        []
        [ div
            [ let
                segmentation =
                    "25px"
              in
              style
                [ ( "display", "flex" )
                , ( "padding", segmentation )
                , ( "width", "calc(100vw - (2 * " ++ segmentation ++ "))" )
                , ( "background-color", "#F5F5F5" )
                ]
            ]
            [ span
                [ style
                    [ ( "font-family", "cursive" )
                    , ( "padding-right", "15px" )
                    ]
                ]
                [ text "fx" ]
            , input
                [ type_ "text"
                , id formulaInputId
                , style
                    [ ( "flex", "1" )
                    , ( "font-family", "monospace" )
                    ]
                , onInput InputFormula
                , value <| Sheet.raw model.selected model.sheet
                ]
                []
            ]
        , table
            [ style
                [ ( "table-layout", "fixed" )
                , ( "border-collapse", "collapse" )
                ]
            ]
            (grid model)
        ]


grid : Model -> List (Html Msg)
grid model =
    loop model.rows <|
        \row ->
            tr [] <|
                loop model.columns <|
                    \column ->
                        cell
                            { current = Sheet.Position row column
                            , selected = model.selected
                            }
                            model.sheet


cell : { current : Sheet.Position, selected : Sheet.Position } -> Sheet.Cells -> Html Msg
cell { current, selected } sheet =
    td
        [ style
            [ ( "border"
              , if current == selected then
                    "double 1px #4184F5"
                else
                    "solid 1px #DADADA"
              )
            , ( "width", "100px" )
            ]
        , onClick <| SelectCell current
        ]
        [ Sheet.render current sheet ]


loop : Int -> (Int -> a) -> List a
loop =
    loopHelp []


loopHelp : List a -> Int -> (Int -> a) -> List a
loopHelp acc n func =
    if n == 0 then
        acc
    else
        loopHelp (func n :: acc) (n - 1) func



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
