{
  inputs,
  self,
  ...
}:
let
  inherit (inputs) nixpkgs nixpkgs-patcher hm;
in
{
  flake =
    let
      lib = nixpkgs-patcher.lib // hm.lib;
      hosts = import "${self}/config/nixos/hosts.nix";
    in
    {
      lib = lib;
      nixosConfigurations =
        let
          specialArgs = { inherit inputs self; };
          inherit (lib) nixosSystem;
          deviceConfigurations = map (host: {
            name = host;
            value = nixosSystem {
              specialArgs = specialArgs;
              nixpkgsPatcher.nixpkgs = nixpkgs;
              nixpkgsPatcher.inputs = inputs;
              modules =
                let
                  hostConfig = import "${self}/config/nixos/${host}/default.nix";
                  hostStaticConfig = import "${self}/config/nixos/${host}/static.nix";
                in
                [
                  {
                    networking.hostName = host;
                    imports = [
                      self.nixosModules.default
                      hostConfig
                      "${self}/config/nixos/company.nix"
                    ];
                    home-manager.extraSpecialArgs = specialArgs;
                    home-manager.users =
                      let
                        users = map (user: {
                          name = user;
                          value = {
                            imports = [
                              self.homeManagerModules.default
                              "${self}/config/home/${host}/${user}/default.nix"
                            ];
                          };
                        }) hostStaticConfig.device.home.users;
                      in
                      builtins.listToAttrs users;
                  }
                ];
            };
          }) hosts;
        in
        builtins.listToAttrs deviceConfigurations;
    };
}
