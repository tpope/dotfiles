import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts
import qualified Data.Map as M

myLayout = toggle $ tiled ||| Mirror tiled ||| Full
  where
    tiled   = Tall 1 (3/100) (1/2)
    toggle = toggleLayouts (noBorders Full)

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [ ((modm .|. controlMask, xK_r), restart "awesome" True)
  , ((modm, xK_f), sendMessage ToggleLayout)
  ]

main = xmonad $ ewmh defaultConfig
  { modMask = mod4Mask
  , keys = myKeys <+> keys defaultConfig
  , layoutHook = myLayout
  , handleEventHook =
    handleEventHook defaultConfig <+> fullscreenEventHook
  }
