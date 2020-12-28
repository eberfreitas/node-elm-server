port module Server exposing (main)

import Json.Decode as D exposing (Value)
import Platform exposing (worker)


type alias Model =
    Int


type Msg
    = Request RequestResolve


type alias RequestResolve =
    { request : Value
    , resolve : Value
    }


type alias RequestInfo =
    { url : String }


main : Program () Model Msg
main =
    worker
        { init = \() -> ( 0, Cmd.none )
        , subscriptions = \_ -> onRequest Request
        , update = update
        }


port onRequest : (RequestResolve -> msg) -> Sub msg


port resolve : ( RequestResolve, Int, String ) -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg count =
    case msg of
        Request ({ request } as requestResolve) ->
            case decodeRequest request of
                Ok { url } ->
                    let
                        ( newCount, status, responseText ) =
                            handleRequest url count
                    in
                    ( newCount
                    , resolve ( requestResolve, status, responseText )
                    )

                Err _ ->
                    ( count
                    , resolve
                        ( requestResolve
                        , 500
                        , "There was an error processing the request"
                        )
                    )


handleRequest : String -> Int -> ( Int, Int, String )
handleRequest url count =
    let
        ok () =
            ( count + 1, 200, String.fromInt count )
    in
    case url of
        "" ->
            ok ()

        "/" ->
            ok ()

        _ ->
            ( count, 404, "Not found" )


decodeRequest : Value -> Result D.Error RequestInfo
decodeRequest value =
    D.decodeValue
        (D.map RequestInfo (D.field "url" D.string))
        value
