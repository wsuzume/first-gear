port module Port exposing(PortMsg, elm2js, js2elm, encodePortMsg, portMsgDecoder, decodePortMsg)

import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (required)

port elm2js : Encode.Value -> Cmd msg
port js2elm : (Decode.Value -> msg) -> Sub msg

type alias PortMsg =
    { tag : String
    , content : String
    }

encodePortMsg : PortMsg -> Encode.Value
encodePortMsg msg
    = Encode.object
        [ ( "tag", Encode.string msg.tag )
        , ( "content", Encode.string msg.content )
        ]

portMsgDecoder : Decoder PortMsg
portMsgDecoder =
    Decode.succeed PortMsg
        |> required "tag" Decode.string
        |> required "content" Decode.string

decodePortMsg : Decode.Value -> Result Decode.Error PortMsg
decodePortMsg msg
    = Decode.decodeValue portMsgDecoder msg

