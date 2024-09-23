module Main where

import Prelude

import Effect (Effect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.VDom.Driver (runUI)
import Yoga.JSON (readJSON_)
import Data.Maybe (Maybe(..), fromMaybe)

rawJson :: String
rawJson = """ { "id": "About", "label": "About Adobe CVG Viewer..." } """

type MenuItem =
  { id :: String
  , label :: Maybe String
  }

item :: Maybe MenuItem
item = readJSON_ rawJson

parsedId = (fromMaybe { id: "JSON parsing fail", label: Nothing } item).id

-- about = item { id }


main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body

data Action = Increment | Decrement

component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
    }
  where
  initialState _ = 0

  render state =
    HH.div_
      [ HH.button [ HE.onClick \_ -> Decrement ] [ HH.text "-" ]
      , HH.text parsedId
      , HH.div_ [ HH.text $ show state ]
      , HH.button [ HE.onClick \_ -> Increment ] [ HH.text "+" ]
      , HH.text rawJson
      ]

  handleAction = case _ of
    Increment -> H.modify_ \state -> state + 1
    Decrement -> H.modify_ \state -> state - 1
