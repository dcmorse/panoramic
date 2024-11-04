module Main where

import Prelude
import Affjax.Web as AX
import Affjax.ResponseFormat as AXRF
import Data.Either (hush)
import Data.Maybe (Maybe(..), isNothing)
import Data.Map as Map
import Data.Array ((:), take)
import Data.Tuple (Tuple, uncurry)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
-- import Web.Event.Event (Event)
-- import Web.Event.Event as Event
import Effect.Console (log)
import Yoga.JSON (readJSON_)

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  runUI component unit body

type Url = String

type Breed = String
type IndexBreedMap = Map.Map Breed (Array Breed)

mapIndexBreedMap :: forall b. (Breed -> Array Breed -> b) -> IndexBreedMap -> Array b
mapIndexBreedMap f bmap = map (uncurry f) alist
  where
    alist :: Array (Tuple Breed (Array Breed))
    alist = Map.toUnfoldable bmap

type State =
  { indexBreedMap :: Maybe IndexBreedMap,
    breedImages :: Map.Map Breed (Maybe (Array Url)), -- if not in map: never requested. If in map with value Nothing: requested but loading, otherwise loaded
    route :: Maybe Breed -- 'Nothing' means the index page
  }

data Action
  = IndexLoad
  | ViewBreed String

instance showAction :: Show Action where
  show IndexLoad = "IndexLoad"
  show (ViewBreed breed) = "ViewBreed " <> show breed

component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just IndexLoad }
    }


initialState :: forall input. input -> State
initialState _ = { indexBreedMap: Nothing, breedImages: Map.empty, route: Nothing }

render :: forall m. State -> H.ComponentHTML Action () m
render st =
  case st.route of
    Just breed ->
      HH.div_ $
        HH.h1_ [ HH.text breed ] : 
        case Map.lookup breed st.breedImages of
          Just (Just urls) -> map (\url -> HH.img [ HP.src url, style]) (take 20 urls)
            where style = HP.style "max-width: 300px; max-height: 300px; width: auto; height: auto"
          Just Nothing -> [ HH.text "Loading image list..." ]
          Nothing -> [ HH.text "Not yet loading image list (this seems like a bug)..." ]
    Nothing ->
      HH.div_
        [ HH.p_
            [ HH.text $ if isNothing st.indexBreedMap then "Loading..." else "" ]
        , HH.div_
            case st.indexBreedMap of
              Nothing -> [ HH.text "no st.result!"]
              Just bmap ->
                [ HH.h1_
                    [ HH.text "Choose Your Dog Breed" ]
                , HH.ul_
                    (map (HH.li_ <<< pure) $ mapIndexBreedMap breedHtml bmap)
                ]
        ]
      where
        breedHtml breed subbreeds = HH.div_ $ [breedLink breed] <> colon subbreeds <> map (HH.text <<< (\x -> " " <> x)) subbreeds
        colon [] = []
        colon _ = [HH.text ":"]
        breedLink s = HH.a [ HE.onClick \_ -> ViewBreed s, HH.attr (HH.AttrName "href") "#" ] [ HH.text s ]
   
    
bodyOf :: forall b rest. { body :: b | rest } -> b
bodyOf x = x.body
messageOf :: forall m rest. { message :: m | rest } -> m
messageOf x = x.message


handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction action = do
  H.liftEffect $ log $ "handleAction triggered with: " <> show action
  case action of
    ViewBreed breed -> do
      st <- H.get
      let
        ensureLoading Nothing = Just Nothing
        ensureLoading x@(Just _) = x
      H.modify_ \s -> s { breedImages = Map.alter ensureLoading breed s.breedImages,
                          route = Just breed
                        }
      case (Map.lookup breed st.breedImages) of
        Nothing -> do
          H.liftEffect $ log $ "cache miss for " <> breed
          response <- H.liftAff $ AX.get AXRF.string $ "https://dog.ceo/api/breed/" <> breed <> "/images"
          H.liftEffect $ log $ "API response: " <> show (hush response)
          let parsed :: Maybe { status :: String, message :: Array Url }
              parsed = join (readJSON_ <$> bodyOf <$> hush response)
              images :: Maybe (Array Url)
              images = messageOf <$> parsed
              updateEntry Nothing = Just images
              updateEntry (Just Nothing) = Just images
              updateEntry x = x -- hm we double GET'ted. Peformance bug. 
          H.liftEffect $ log $ "updating image cache urls for " <> breed
          H.modify_ \s -> s { breedImages = Map.alter updateEntry breed s.breedImages }      
        Just _ -> do
          H.liftEffect $ log $ "cache hit for " <> breed
    IndexLoad -> do
      -- Log page load event
      H.liftEffect $ log "IndexLoad action triggered"
      
      -- Log that the API request is being made
      H.liftEffect $ log "Making API request to get breed list."
      
      -- Make the API request
      response <- H.liftAff $ AX.get AXRF.string "https://dog.ceo/api/breeds/list/all"
      
      let maybeResponse = hush response

      -- Log the response
      H.liftEffect $ log $ "API response: " <> show maybeResponse

      let maybeBody :: Maybe String
          maybeBody = bodyOf <$> maybeResponse
          parsed :: Maybe { status :: String, message :: Map.Map Breed (Array Breed) }
          parsed = join (readJSON_ <$> maybeBody)

      H.liftEffect $ log $ "status: " <> show parsed

      -- Update state based on the API response
      H.modify_ \s -> s
        { indexBreedMap = messageOf <$> parsed
        }
      
      -- Log completion of the action
      H.liftEffect $ log "IndexLoad action completed, indexBreedMap is a Just Map"

