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

          ignorealpha = [
            "waybar,blur on"
            "waybar,ignore_alpha 0"
            "notifications,ignore_alpha 0,blur on"
            "osd"
            "system-menu"
            "anyrun"
          ];

          layers = ignorealpha ++ [
            "bar"
            "gtk-layer-shell"
          ];
        in
        [
          "${toRegex layers}, blur on"
          "${
            toRegex [
              "bar"
              "gtk-layer-shell"
            ]
          }, xray on"
          "${
            toRegex [
              "bar"
              "gtk-layer-shell"
            ]
          }, ignore_alpha 0.2"
          "${toRegex (ignorealpha ++ [ "music" ])}, ignore_alpha 0.5"
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
