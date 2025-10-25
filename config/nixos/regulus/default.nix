{
  imports = [
    ./static.nix
    ./generated.nix
    # Need to run services not inteded for this thesis
    ./homelab.nix
  ];
}
