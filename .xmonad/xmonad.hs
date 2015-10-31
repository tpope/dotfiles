import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place
import XMonad.Hooks.UrgencyHook
import XMonad.Layout
import XMonad.Layout.Fullscreen
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce

myLayout = toggle $ tallLayout ||| wideLayout ||| fullLayout
  where
    basicLayout = smartBorders $ fullscreenFocus $ Tall 1 (3/100) (1/2)
    tallLayout  = named "Tall" $ avoidStruts $ basicLayout
    wideLayout  = named "Wide" $ avoidStruts $ Mirror $ basicLayout
    fullLayout  = named "Full" $ noBorders Full
    toggle = toggleLayouts fullLayout

myManageHook = composeAll (
  [ stringProperty "WM_WINDOW_ROLE" =? "pop-up" --> doFloat
  , className =? "Pavucontrol" --> doFloat
  , className =? "Arandr" --> doFloat
  , className =? "Xmessage" --> doFloat
  , className =? "Xmag" --> doFloat
  , title =? "Event Tester" --> doFloat
  ])

main = xmonad $ withUrgencyHook BorderUrgencyHook {urgencyBorderColor = "yellow"}
              $ ewmh
              $ desktopConfig
  { modMask = modm
  , terminal = "tpope terminal"
  , layoutHook = myLayout
  , manageHook =
    fullscreenManageHook <+> manageHook desktopConfig <+> myManageHook
  , handleEventHook =
    handleEventHook defaultConfig <+> fullscreenEventHook
  }
  `removeKeys`
  [ (modm .|. shiftMask, xK_slash)
  , (modm, xK_question)
  , (modm, xK_p)
  , (modm .|. shiftMask, xK_p)
  ]
  `additionalKeys`
  [ ((modm .|. controlMask, xK_r), restart "awesome" False)
  , ((modm, xK_f), sendMessage (Toggle "Full"))
  , ((modm, xK_u), focusUrgent)
  ]
  where modm = mod4Mask
