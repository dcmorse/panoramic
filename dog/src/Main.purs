module Main where

import Prelude
import Affjax.Web as AX
import Affjax.ResponseFormat as AXRF
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Data.Map (Map, keys, toUnfoldable)
import Data.Array (fromFoldable, (:))
import Data.Tuple (Tuple(..), uncurry)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.HTML as HH
-- import Halogen.HTML.Events as HE
-- import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
-- import Web.Event.Event (Event)
-- import Web.Event.Event as Event
import Effect.Console (log)
import Yoga.JSON (readJSON_)

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  runUI component unit body

type BreedMap = Map String (Array String)

mapBreedMap :: forall b. (String -> Array String -> b) -> BreedMap -> Array b
mapBreedMap f bmap = map (uncurry f) alist
  where
    alist :: Array (Tuple String (Array String))
    alist = toUnfoldable bmap

type State =
  { loading :: Boolean
  , breedMap :: Maybe BreedMap
  }

data Action
  = PageLoad

instance showAction :: Show Action where
  show PageLoad = "PageLoad"

component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just PageLoad }
    }


initialState :: forall input. input -> State
initialState _ = { loading: false, breedMap: Nothing }

render :: forall m. State -> H.ComponentHTML Action () m
render st =
  HH.div_
    [ HH.p_
        [ HH.text $ if st.loading then "Loading..." else "" ]
    , HH.div_
        case st.breedMap of
          Nothing -> [ HH.text "no st.result!"]
          Just bmap ->
            [ HH.h2_
                [ HH.text "Response" ]
            , HH.ul_
                (map (HH.li_ <<< pure) $ mapBreedMap breedHtml bmap)
            ]
    ]
  where
    breedHtml breed subbreeds = HH.div_ $ HH.text (breed <> maybeColon subbreeds) : map (HH.text <<< (\x -> " " <> x)) subbreeds
    maybeColon [] = ""
    maybeColon _ = ":"

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction action = do
  H.liftEffect $ log $ "handleAction triggered with: " <> show action
  case action of
    PageLoad -> do
      -- Log page load event
      H.liftEffect $ log "PageLoad action triggered, setting loading to true."
      
      -- Set loading state to true
      H.modify_ \s -> s { loading = true }
      
      -- Log that the API request is being made
      H.liftEffect $ log "Making API request to get breed list."
      
      -- Make the API request
      response <- H.liftAff $ AX.get AXRF.string "https://dog.ceo/api/breeds/list/all"
      
      let maybeResponse = hush response

      -- Log the response
      H.liftEffect $ log $ "API response: " <> show maybeResponse

      let bodyOf x = x.body
          messageOf x = x.message
          maybeBody :: Maybe String
          maybeBody = bodyOf <$> maybeResponse
          parsed :: Maybe { status :: String, message :: Map String (Array String) }
          parsed = join (readJSON_ <$> maybeBody)

      H.liftEffect $ log $ "status: " <> show parsed

      -- Update state based on the API response
      H.modify_ \s -> s
        { loading = false
        , breedMap = messageOf <$> parsed
        }
      
      -- Log completion of the action
      H.liftEffect $ log "PageLoad action completed, loading set to false."

