{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE MultiWayIf #-}

module System.Power where

import Foreign.C.Types
import Data.Bits
import Control.Monad

data SetPower = RequireDisplay
              | RequireSystem
              | RequireDisplayAndSystem
              | Default
              deriving (Eq, Show)
              
type Error = String

suggestPower :: SetPower -> IO ()
currentPower :: IO SetPower


#ifdef mingw32_HOST_OS

foreign import ccall "SetThreadExecutionState" win_SetThreadExecutionState :: CUInt -> IO CUInt

es_CONTINUOUS        = CUInt 0x80000000
es_AWAYMODE_REQUIRED = CUInt 0x00000040
es_DISPLAY_REQUIRED  = CUInt 0x00000002
es_SYSTEM_REQUIRED   = CUInt 0x00000001

suggestPower Default                  = void $ win_SetThreadExecutionState $ es_CONTINUOUS
suggestPower RequireDisplay           = void $ win_SetThreadExecutionState $ es_CONTINUOUS .|. es_DISPLAY_REQUIRED
suggestPower RequireSystem            = void $ win_SetThreadExecutionState $ es_CONTINUOUS .|. es_SYSTEM_REQUIRED
suggestPower RequireDisplayAndSystem  = void $ win_SetThreadExecutionState $ es_CONTINUOUS .|. es_DISPLAY_REQUIRED .|. es_SYSTEM_REQUIRED 

currentPower = do 
   r <- win_SetThreadExecutionState es_CONTINUOUS
   win_SetThreadExecutionState r
   return $ if
      | r == es_CONTINUOUS                                                -> Default
      | r == es_CONTINUOUS .|. es_DISPLAY_REQUIRED                        -> RequireDisplay
      | r == es_CONTINUOUS .|. es_SYSTEM_REQUIRED                         -> RequireSystem
      | r == es_CONTINUOUS .|. es_DISPLAY_REQUIRED .|. es_SYSTEM_REQUIRED -> RequireDisplayAndSystem

#endif

#ifdef darwin_HOST_OS

suggestPower _ = return ()
currentPower = return Default

#endif
