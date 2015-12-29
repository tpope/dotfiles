import System.Exit
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
import qualified XMonad.StackSet as W
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

myExit :: X ()
myExit = do
  spawn "pkill -f \"taffybar.* --display $DISPLAY\""
  return ()

main = xmonad $ withUrgencyHook BorderUrgencyHook {urgencyBorderColor = "yellow"}
              $ ewmh
              $ desktopConfig
  { modMask = modm
  , terminal = "tpope terminal"
  , handleEventHook =
    handleEventHook defaultConfig <+> fullscreenEventHook
  , layoutHook = myLayout
  , manageHook =
    fullscreenManageHook <+> manageHook desktopConfig <+> myManageHook
  , startupHook =
    spawnOnce "test -z \"$XDG_MENU_PREFIX\" -a -d \"$HOME/.config/taffybar\" && taffybar --display $DISPLAY"
  }
  `removeKeys`
  [ (modm .|. shiftMask, xK_slash)
  , (modm, xK_question)
  , (modm, xK_p)
  , (modm .|. shiftMask, xK_p)
  ]
  `additionalKeys`
  [ ((modm .|. shiftMask  , xK_q), myExit >> io (exitWith ExitSuccess))
  , ((modm .|. controlMask, xK_r), myExit >> restart "awesome" False)
  , ((modm                , xK_f), sendMessage (Toggle "Full"))
  , ((modm                , xK_a), windows W.focusMaster)
  , ((modm .|. shiftMask  , xK_a), windows W.swapMaster)
  , ((modm                , xK_u), focusUrgent)
  , ((modm                , xK_v), focusUrgent)
  ]
  where modm = mod4Mask
