import System.Power
import Test.Hspec

main :: IO ()
main = hspec $ do
   describe "System.Power" $ do
      it "currentPower" $ do
         currentPower >>= (`shouldBe` Default)
      it "requirePower" $ do
         suggestPower RequireDisplayAndSystem
         currentPower >>= (`shouldBe` RequireDisplayAndSystem)
         currentPower >>= (`shouldBe` RequireDisplayAndSystem)
         suggestPower RequireDisplay
         currentPower >>= (`shouldBe` RequireDisplay)
         currentPower >>= (`shouldBe` RequireDisplay)
         suggestPower RequireSystem
         currentPower >>= (`shouldBe` RequireSystem)
         currentPower >>= (`shouldBe` RequireSystem)
