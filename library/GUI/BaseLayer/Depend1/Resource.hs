{-# LANGUAGE StrictData #-}
-- |
-- Module:      GUI.BaseLayer.Depend1.Resource
-- Copyright:   (c) 2017 KolodeznyDiver
-- License:     BSD3
-- Maintainer:  KolodeznyDiver <KldznDvr@gmail.com>
-- Stability:   experimental
-- Portability: portable
--
-- Типы относящиеся к менеджеру ресурсов, "GUI.BaseLayer.Resource" и вынесенные в отдельный файл
-- для исключения циклической зависимости модулей.

module GUI.BaseLayer.Depend1.Resource(
    -- * Типы относящиеся к менеджеру ресурсов, "GUI.BaseLayer.Resource" и вынесенные в отдельный файл
    -- для исключения циклической зависимости модулей.
    CachedItem,CacheCollection,GuiFontOptions(..),GuiFontDef(..),FontCollectionItem(..),FontCollection
    ,NaturalStringCollection,CursorCollection,ResourceManager(..)
                        ) where
import qualified Data.HashMap.Strict as HM
import           Data.ByteString.Char8   (ByteString)
import qualified Data.Text as T
import Data.IORef
import Data.Default
import qualified SDL
import qualified SDL.Font as FNT
import GUI.BaseLayer.Depend0.Cursor

-- | Тип элемента коллеции. Тип введён для упрощения замены значений на ссылки, если это потребуется.
type CachedItem a = a

-- | Обобщённая коллеция менеджера ресурсов. Ключи имеют тип 'T.Text', т.к. они, одновременно могут быть
-- именем файла.
type CacheCollection a = HM.HashMap T.Text (CachedItem a)

-- | Тип коллеции кешируемых графических файлов в виде 'Surface' т.е., не привязанных к конкретному окну.
type SurfaceCollection = CacheCollection SDL.Surface

-- | Тип коллеции строк естественного языка из файлов /I18n/ru_RU/*.txt.
type NaturalStringCollection = HM.HashMap ByteString T.Text

-- | Дополнительные параметры шрифта используемые в 'GuiFontDef'
data GuiFontOptions = GuiFontOptions {
      fontKerning :: Maybe FNT.Kerning -- ^ Настроить кернинг шрифта или оставить по умолчанию.
    , fontHinting :: Maybe FNT.Hinting -- ^ Настроить хинтинг шрифта или оставить по умолчанию.
    , fontOutline :: Maybe FNT.Outline -- ^ Настроить Outline шрифта или оставить по умолчанию.
    , fontStyle   :: Maybe [FNT.Style] -- ^ Настроить стили шрифта или оставить по умолчанию.
                                     }
                                 deriving ( Eq, Show )

instance Default GuiFontOptions where
    def = GuiFontOptions { fontKerning = Nothing
                         , fontHinting = Nothing
                         , fontOutline = Nothing
                         , fontStyle   = Nothing
                         }

-- | Элемент списка предзагруженных шрифтов, передаваемый функции @GUI.BaseLayer.RunGUI.runGUI@.
data GuiFontDef = GuiFontDef{
      fontAbbrev    :: T.Text -- ^ Сокращённое название, ключ шрифта, по которому он будет доступен в коллекции.
    , fontPath      :: String  -- ^ Имя файла шрифта. Если путь не указан или он относительный, то шрифт
                               -- должен находиться в директории ресурсов.
    , fontPtSz      :: Int -- ^ Размер шрифта в пунктах.
    , fontOpts      :: GuiFontOptions -- ^ Дополнительные параметры шрифта.
    }

-- | Элемент коллеции кешируемых шрифтов
data FontCollectionItem = FontCollectionItem {
      fntPath      :: String -- ^ Имя файла шрифта из 'GuiFontDef'.
    , fntPtSz      :: Int -- ^ Размер шрифта в пунктах из 'GuiFontDef'.
    , fntOpts      :: GuiFontOptions -- ^ Дополнительные параметры шрифта из 'GuiFontDef'.
    , fnt          :: FNT.Font -- ^ Загруженный и настроенный шрифт.
                                             }

-- | Тип коллеции кешируемых шрифтов.
type FontCollection = CacheCollection FontCollectionItem

-- | Тип коллеции кешируемых курсоров.
type CursorCollection = CacheCollection GuiCursor

-- | Тип менеджера ресурсов.
data ResourceManager = ResourceManager {
      resPath   :: FilePath -- ^ Полный путь к директории ресурсов.
    , skinPath  :: FilePath -- ^ Полный путь к директории текущего скина.
    , systemCursorSet :: CursorSet -- ^ Загруженные системные курсоры.
    , userCursors :: IORef CursorCollection -- ^ Загруженные курсоры пользователя.
    , surfaces  :: IORef SurfaceCollection -- ^ Коллекция загруженных графических файлов в виде
                                           -- 'Surface', т.е. не привязанных к конкретному окну.
    , fonts     :: IORef FontCollection -- ^ Коллекция загруженных шрифтов.
    -- | Cтроки естественного языка из файлов /I18n/ru_RU/*.txt.
    , natStrs :: NaturalStringCollection
                                       }

