{
  pkgs,
  modpack,
  ...
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "minecraft-server-forge";
  version = "forge-1.7.10-10.13.4.1614-1.7.10";
  meta.mainProgram = "server";

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    mkdir -p $out/bin

    cp "${modpack}/java9args.txt" "$out/bin/unix_args.txt"
    cp "${modpack}/lwjgl3ify-forgePatches.jar" "$out/bin/lwjgl3ify-forgePatches.jar"
  '';

  installPhase = ''
    cat <<\EOF >>$out/bin/server
    ${pkgs.jre_headless}/bin/java "$@" "@${builtins.placeholder "out"}/bin/unix_args.txt" -jar "${builtins.placeholder "out"}/bin/lwjgl3ify-forgePatches.jar" nogui
    EOF

    chmod +x $out/bin/server
  '';
}
