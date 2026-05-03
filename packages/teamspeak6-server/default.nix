{
  lib,
  stdenv,
  fetchurl,
  libpq,
  autoPatchelfHook,
  writeScript,
}:
let
  majorVersion = "6.0.0";
  betaTag = "beta9";
in
stdenv.mkDerivation rec {
  pname = "teamspeak6-server";
  version = "${majorVersion}-${betaTag}";
  sourceRoot = ".";
  # https://github.com/teamspeak/teamspeak6-server/releases/download/v6.0.0%2Fbeta7/teamspeak-server_linux_amd64-v6.0.0-beta7.tar.bz2
  src = fetchurl {
    # https://github.com/teamspeak/teamspeak6-server/releases/download/v6.0.0-beta9/teamspeak6-server-linux-amd64.tar.xz

    url = "https://github.com/teamspeak/teamspeak6-server/releases/download/v${majorVersion}-${betaTag}/teamspeak6-server-linux-amd64.tar.xz";
    sha256 = "sha256-vC6G7KhI6cBZiSEp7oeG0BVzjREVxN2PaXsGBNULN3I=";
  };

  buildInputs = [
    stdenv.cc.cc
    libpq
  ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    # Install files.
    mkdir -p $out/lib/teamspeak
    mv * $out/lib/teamspeak/

    # Make symlinks to the binaries from bin.
    mkdir -p $out/bin/
    ln -s $out/lib/teamspeak/tsserver $out/bin/tsserver

    runHook postInstall
  '';

  passthru.updateScript = writeScript "update-teampeak-server" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts curl gnugrep gnused jq pup

    set -eu -o pipefail

    version=$( \
      curl https://www.teamspeak.com/en/downloads/ \
        | pup "#server .linux .version json{}" \
        | jq -r ".[0].text"
    )

    versionOld=$(nix-instantiate --eval --strict -A "teamspeak_server.version")

    nixFile=pkgs/applications/networking/instant-messengers/teamspeak/server.nix

    update-source-version teamspeak_server "$version" --system=i686-linux

    sed -i -e "s/version = \"$version\";/version = $versionOld;/" "$nixFile"

    update-source-version teamspeak_server "$version" --system=x86_64-linux
  '';

  meta = {
    description = "TeamSpeak voice communication server";
    homepage = "https://teamspeak.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.teamspeak;
    platforms = [ "x86_64-linux" ];
  };
}
