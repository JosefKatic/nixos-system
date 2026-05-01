# Standard layout for wrapFirefox nativeMessagingHosts — see nixpkgs firefox wrapper.nix
# (symlinks into $MOZ_HOME/native-messaging-hosts on launch; Zen uses ~/.zen).
{
  lib,
  pkgs,
  ...
}:
let
  appFish = ./native_app/app.fish;
  runner = pkgs.writeShellScript "caelestiafox" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.fish
        pkgs.jq
        pkgs.inotify-tools
      ]
    }"
    exec ${pkgs.fish}/bin/fish ${appFish} "$@"
  '';
in
pkgs.runCommand "caelestiafox-native-messaging-host" { } ''
    mkdir -p $out/lib/mozilla/native-messaging-hosts $out/bin
    install -Dm755 ${runner} $out/bin/caelestiafox
    cat > $out/lib/mozilla/native-messaging-hosts/caelestiafox.json <<EOF
  {
    "name": "caelestiafox",
    "description": "Native app for CaelestiaFox extension.",
    "path": "$out/bin/caelestiafox",
    "type": "stdio",
    "allowed_extensions": ["caelestiafox@caelestia.org"]
  }
  EOF
''
