# Upstream: https://github.com/caelestia-dots/caelestia/tree/main/vscode/caelestia-vscode-integration
# Unpacked copy used only when `code --install-extension` / `cursor --install-extension` fails (e.g. headless switch).
{
  lib,
  pkgs,
  vsix,
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "caelestia-vscode-integration";
  version = "1.2.0";
  src = vsix;

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip -q "$src" -d vsix
  '';

  installPhase = ''
    mkdir -p $out
    cp -r vsix/extension/* $out/
  '';

  meta = {
    description = "VS Code / Cursor integration: live Caelestia theme from scheme.json";
    homepage = "https://github.com/caelestia-dots/caelestia/tree/main/vscode";
    license = lib.licenses.mit;
  };
}
