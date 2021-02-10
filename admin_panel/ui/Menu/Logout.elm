module Menu.Logout exposing (..)

import Json.Decode
import Json.Decode.Pipeline exposing (decode, required, optional, resolve, hardcoded)

type alias LogOutResp = { redirect: String }

logoutRespDecoder : Json.Decode.Decoder (LogOutResp)
logoutRespDecoder =
  decode LogOutResp
    |> required "redirect" Json.Decode.string
