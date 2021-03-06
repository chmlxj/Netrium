-- |Netrium is Copyright Anthony Waite, Dave Hetwett, Shaun Laurens 2009-2015, and files herein are licensed
-- |under the MIT license,  the text of which can be found in license.txt
--
module UnitsDB where

import Control.Monad              (liftM, liftM2)
import Text.XML.HaXml.XmlContent
import Text.XML.HaXml.Types
import XmlUtils

newtype UnitsDB = UnitsDB { unUnitsDB :: [UnitDecl] }
  deriving (Show, Read)

data UnitDecl = CommodityDecl    String
              | UnitDecl         String
              | LocationDecl     String
              | CurrencyDecl     String
              | CashFlowTypeDecl String
  deriving (Show, Read)


instance HTypeable UnitsDB where
  toHType _ = Defined "UnitsDB" [] []

instance XmlContent UnitsDB where
  parseContents = inElement "UnitsDB" (liftM UnitsDB parseContents)
  toContents (UnitsDB ds) = [mkElemC "UnitsDB" (toContents ds)]


instance HTypeable UnitDecl where
  toHType _ = Defined "UnitDecl" [] []

instance XmlContent UnitDecl where
  parseContents = do
    e@(Elem t _ _) <- element ["CommodityDecl", "CashFlowTypeDecl",
                               "UnitDecl",
                               "LocationDecl", "CurrencyDecl"]
    commit $ interior e $ case t of
      N "CashFlowTypeDecl"  -> liftM CashFlowTypeDecl  (attrStr (N "name") e)
      N "CommodityDecl"     -> liftM CommodityDecl     (attrStr (N "name") e)
      N "UnitDecl"          -> liftM UnitDecl          (attrStr (N "name") e)
      N "LocationDecl"      -> liftM LocationDecl      (attrStr (N "name") e)
      N "CurrencyDecl"      -> liftM CurrencyDecl      (attrStr (N "name") e)

  toContents (CommodityDecl n ) =
    [mkElemAC (N "CommodityDecl") [((N "name"), str2attr n)] []]
  toContents (CashFlowTypeDecl n ) =
    [mkElemAC (N "CashFlowTypeDecl") [((N "name"), str2attr n)] []]
  toContents (UnitDecl n ) =
    [mkElemAC (N "UnitDecl") [((N "name"), str2attr n)] []]
  toContents (LocationDecl n ) =
    [mkElemAC (N "LocationDecl") [((N "name"), str2attr n)] []]
  toContents (CurrencyDecl n ) =
    [mkElemAC (N "CurrencyDecl") [((N "name"), str2attr n)] []]


compileUnitsDB :: UnitsDB -> String
compileUnitsDB = unlines . map compileUnit . unUnitsDB
  where
    compileUnit (CashFlowTypeDecl n) =
      n ++ " :: CashFlowType\n" ++
      n ++ " = CashFlowType " ++ show n
    compileUnit (CommodityDecl n) =
      n ++ " :: Commodity\n" ++
      n ++ " = Commodity " ++ show n
    compileUnit (UnitDecl n) =
      n ++ " :: Unit\n" ++
      n ++ " = Unit " ++ show n
    compileUnit (LocationDecl n) =
      n ++ " :: Location\n" ++
      n ++ " = Location " ++ show n
    compileUnit (CurrencyDecl n) =
      n ++ " :: Currency\n" ++
      n ++ " = Currency " ++ show n
