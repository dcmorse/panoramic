module Main where

import Prelude
import Affjax.Web as AX
import Affjax.ResponseFormat as AXRF
import Data.Either (hush)
import Data.Maybe (Maybe(..), isNothing)
import Data.Map as Map
import Data.Array (slice, length)
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
  { route :: Maybe Breed, -- 'Nothing' means the index page

    -- Breed List page state
    indexBreedMap :: Maybe IndexBreedMap,

    -- Breed Details page state

    breedImages :: Map.Map Breed (Maybe (Array Url)),
    -- there are three possible states for a breedImages entry:
    -- 1. the key has a value of `Just (Array String)`, meaning it's loaded a list of zero or more dog image urls, hooray!
    -- 2. the key has a value of `Nothing`, meaning we're waiting for the afore mentioned list to load
    -- 3. the key is not present, meaning it's never attempted to load a list of dog image urls.
    -- Obviously this long comment, and the fact that there's no encoding for http error, is a code smell.
    -- Hopefully this is good enough for now. 
    
    paginationOffset :: Int -- only used for BreedDetails pages
  }

data Action
  = IndexLoad
  | ViewBreed String
  | ViewIndex
  | PageDecrement
  | PageIncrement

instance showAction :: Show Action where
  show IndexLoad = "IndexLoad"
  show (ViewBreed breed) = "ViewBreed " <> show breed
  show ViewIndex = "ViewIndex"
  show PageDecrement = "PageDecrement"
  show PageIncrement = "PageIncrement"

component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just IndexLoad }
    }

initialState :: forall input. input -> State
initialState _ = { indexBreedMap: Nothing,
                   breedImages: Map.empty,
                   route: Nothing,
                   paginationOffset: 0
                 }

render :: forall m. State -> H.ComponentHTML Action () m
render st =
  case st.route of
    Just breed -> -- Breed Details page
      HH.div_ $
        [ HH.a [ HE.onClick \_ -> ViewIndex, HH.attr (HH.AttrName "href") "#" ] [ HH.text "all dog breeds" ],
          HH.h1_ [ HH.text breed ] ] <>
        case Map.lookup breed st.breedImages of
          Just (Just urls) -> navbar <> imagesContainer
            where
              imagesContainer = [ HH.div [ HP.style "display: flex; flex-wrap: wrap; justify-content: space-between; gap: 30px 10px" ] images ]
              images = map (\url -> HH.img [ HP.src url, style]) (slice offset (offset+20) urls)
              offset = st.paginationOffset
              style = HP.style "max-height: 200px; width: auto"
              navbar = [ HH.div [ HP.style "margin-bottom: 30px" ] [ prevPage, numberOfImagesText, nextPage ] ]
              numberOfImagesText = HH.text $ " " <> show (length urls) <> " " <> imagesText <> " "
              prevPage = HH.button [ HE.onClick \_ -> PageDecrement, HP.disabled (offset <= 0) ] [ HH.text "<page" ]
              nextPage = HH.button [ HE.onClick \_ -> PageIncrement, HP.disabled (offset + 20 >= length urls) ] [ HH.text "page>" ]
              imagesText =  if (length urls) == 1 then "image" else "images"
          Just Nothing -> [ HH.text "Loading image list..." ]
          Nothing -> [ HH.text "Not yet loading image list (seeing this seems like a bug)..." ]
    Nothing -> -- Breed List page
      HH.div_
        [ HH.p_
            [ HH.text $ if isNothing st.indexBreedMap then "Loading..." else "" ]
        , HH.div_
            case st.indexBreedMap of
              Nothing -> [ HH.text "Probable parse error loading list of dog breeds!"]
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
    PageDecrement -> do
      H.modify_ \s -> s { paginationOffset = s.paginationOffset - 20 }
    PageIncrement -> do
      H.modify_ \s -> s { paginationOffset = s.paginationOffset + 20 }
    ViewIndex -> do
      H.modify_ \s -> s { route = Nothing, paginationOffset = 0 }
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
      H.liftEffect $ log "IndexLoad action triggered, making API request to get the breed list"
      response <- H.liftAff $ AX.get AXRF.string "https://dog.ceo/api/breeds/list/all"
      let maybeResponse = hush response
      H.liftEffect $ log $ "API response: " <> show maybeResponse
      let maybeBody :: Maybe String
          maybeBody = bodyOf <$> maybeResponse
          parsed :: Maybe { status :: String, message :: Map.Map Breed (Array Breed) }
          parsed = join (readJSON_ <$> maybeBody)
      H.liftEffect $ log $ "status: " <> show parsed
      H.modify_ \s -> s
        { indexBreedMap = messageOf <$> parsed
        }
      H.liftEffect $ log "IndexLoad action completed, indexBreedMap is a Just Map"

