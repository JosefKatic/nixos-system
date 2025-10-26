{
  flake.nixosModules = {
    default = import ./devices;
  };
}
