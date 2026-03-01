{
  config,
  lib,
  ...
}:
let
  cfg = config.user.desktop.wayland.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # layer rules
      layerrule =
        let
          toRegex =
            list:
            let
              elements = lib.concatStringsSep "|" list;
            in
            "match:namespace ^(${elements})$";

          lowopacity = [
            "quickshell:notifications:overlay"
            "quickshell:osd"
          ];

          highopacity = [
            "vicinae"
            "osd"
            "logout_dialog"
            "quickshell:sidebar"
          ];

          blurred = lib.concatLists [
            lowopacity
            highopacity
            [ "quickshell:bar" ]
          ];

          xray = [
            "quickshell:bar"
          ];

          no_anim = [
            "quickshell:notifications:overlay"
            "quickshell:sidebar"
          ];
        in
        [
          "${toRegex blurred}, blur true"
          "${toRegex xray}, xray true"
          "${toRegex lowopacity}, ignore_alpha 0.2"
          "${toRegex highopacity}, ignore_alpha 0.5"
          "match:namespace ^quickshell.*$, blur_popups true"
          "${toRegex [ "quickshell:bar" ]}, ignore_alpha 0.1"
          "${toRegex no_anim}, no_anim true"
        ];

      # window rules
      windowrule = [
        "match:title ^(.*Proton Pass.*)$, size 800 600, float on, pin on, center on, dim_around on"
        # allow tearing in games
        "match:class ^(osu\!|cs2)$, immediate on"

        # make Firefox PiP window floating and sticky
        "match:title ^(Picture-in-Picture)$, float on, pin on"

        # throw sharing indicators away
        "match:title ^(Firefox — Sharing Indicator)$, workspace special silent"
        "match:title ^(.*is sharing (your screen|a window)\.)$, workspace special silent"

        # idle inhibit while watching videos
        "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
        "match:class ^(firefox|zen|brave|chromium)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
        "match:content ^(2|3)$, idle_inhibit focus"
        "match:content ^(2|3)$, idle_inhibit fullscreen"
        "match:class ^(firefox|zen|brave|chromium)$, idle_inhibit fullscreen"

        "match:class ^(gcr-prompter)$, dim_around on"
        # fix xwayland apps
        "match:xwayland true, rounding 0"
      ];
    };
  };
}
