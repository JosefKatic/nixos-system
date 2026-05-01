{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.programs.browsers;
  caelestiaShell = config.user.desktop.wayland.shell.enable;

  # Rendered by caelestia-cli (apply_user_templates); must match paths.theme in caelestia utils/paths.py
  caelestiaZenUserChromeRendered = "${config.home.homeDirectory}/.local/state/caelestia/theme/userChrome.css";

  zenBase = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Zen is wrapFirefox-based; native hosts must be passed here so the wrapper symlinks
  # manifests into $MOZ_HOME/native-messaging-hosts (Zen → ~/.zen). A plain
  # ~/.mozilla/native-messaging-hosts file is easy to miss because Zen does not use that path.
  # See https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_manifests
  zenPackage =
    if caelestiaShell then
      zenBase.override {
        nativeMessagingHosts = [
          (pkgs.callPackage ./caelestiafox-native-messaging-host.nix { })
        ];
      }
    else
      zenBase;
in
{
  options.user.desktop.programs.browsers.zen.enable = lib.mkEnableOption "Enable Zen browser";

  config = lib.mkIf cfg.zen.enable (
    lib.mkMerge [
      {
        home.packages = [ zenPackage ];
      }

      (lib.mkIf caelestiaShell {
        # Flat filename: caelestia-cli only iterates ~/.config/caelestia/templates/* (files), not subdirs.
        xdg.configFile."caelestia/templates/userChrome.css".source = ./userChrome.css;

        home.activation.ensureCaelestiaZenUserChrome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${config.home.homeDirectory}/.local/state/caelestia/theme"
          _f=${lib.escapeShellArg caelestiaZenUserChromeRendered}
          if [ ! -f "$_f" ]; then
            printf '%s\n' \
              '/* Placeholder until caelestia applies a scheme (nh home switch, then change scheme) */' \
              ':root { --c-accent: #7aa2f7 !important; --c-text: #c0caf5 !important;' \
              '--c-mantle: #1a1b26 !important; --c-base: #16161e !important;' \
              '--c-surface0: #24283b !important; --c-surface1: #414868 !important; }' \
              > "$_f"
          fi
        '';

        home.activation.caelestiaZenUserChrome =
          lib.hm.dag.entryAfter
            [
              "writeBoundary"
              "ensureCaelestiaZenUserChrome"
            ]
            ''
              set -eu
              shopt -s nullglob
              _src=${lib.escapeShellArg caelestiaZenUserChromeRendered}
              for _zen in "${config.home.homeDirectory}"/.zen/*; do
                [ -d "$_zen" ] || continue
                _chrome="$_zen/chrome"
                mkdir -p "$_chrome"
                ln -sf "$_src" "$_chrome/userChrome.css"
                _uj="$_zen/user.js"
                if [ ! -f "$_uj" ] || ! grep -qF 'toolkit.legacyUserProfileCustomizations.stylesheets' "$_uj" 2>/dev/null; then
                  echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$_uj"
                fi
              done
            '';
      })
    ]
  );
}
