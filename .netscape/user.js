// Author: Tim Pope
// -*- javascript -*- vim: ft=javascript

// This file configures everything from Netscape 4 to Firefox

with (PrefConfig) {
user_pref("advanced.system.supportDDEExec", false);
user_pref("browser.blink_allowed", false);
user_pref("browser.block.target_new_window", true);
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.tabs.autoHide", false);
user_pref("browser.tabs.extensions.default.type", 1);
user_pref("browser.tabs.extensions.direction_of_focusing", 3);
user_pref("browser.tabs.extensions.last_tab_closing", 1);
user_pref("browser.tabs.extensions.open_tab_in", 2);
user_pref("browser.tabs.extensions.prevent_same_uri_tab", true);
user_pref("browser.tabs.extensions.show_item.moveLeft", true);
user_pref("browser.tabs.extensions.show_item.moveRight", true);
user_pref("browser.tabs.extensions.slow_down_autoreload_in_background.enabled", true);
user_pref("browser.tabs.extensions.window_hook_mode", 1);
user_pref("browser.tabs.opentabfor.windowopen", true);
user_pref("content.notify.backoffcount", 200);
user_pref("content.notify.interval", 120000);
user_pref("content.notify.ontimer", true);
user_pref("dom.disable_open_click_delay", 0);
user_pref("dom.disable_open_during_load", true);
user_pref("dom.disable_window_flip", true);
user_pref("dom.disable_window_move_resize", true);
user_pref("dom.disable_window_open_feature.status", true);
user_pref("dom.disable_window_status_change", true);
user_pref("editor.html_editor", "vim -g %f");
user_pref("editor.image_editor", "gimp %f");
user_pref("editor.use_html_editor", 1);
user_pref("googlebar.country2Search", 71);
user_pref("imageblocker.enable", true);
user_pref("mailnews.headers.showUserAgent", true);
user_pref("mailnews.reply_on_top", 0);
user_pref("network.http.pipelining", true);
user_pref("network.http.proxy.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 100);
user_pref("nglayout.initialpaint.delay", 50);
//user_pref("privacy.popups.firstTime", false);
//user_pref("security.warn_submit_insecure", false);
}
