{ pkgs, ... }:
let
  minecraftVersion = "1.7.10";
  forgeVersion = "10.13.4.1614-1.7.10";
  version = "${minecraftVersion}-${forgeVersion}";
in
pkgs.runCommand "forge-${version}"
  {
    inherit version;
    nativeBuildInputs = with pkgs; [
      cacert
      curl
      jre_headless
    ];

    outputHashMode = "recursive";
    outputHash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
  }
  ''
    mkdir -p "$out"

    curl https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar -o ./installer.jar
    java -jar ./installer.jar --installServer "$out"
  ''
