{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
  };
  outputs =
    { self, ... }@inputs:
    let
      targets = [
        #"x86_64-linux"
        "i686-linux"
        #"aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
        "powerpc64-linux"
      ];
      #packages-x32 = import ./config/packages-x32.nix;
      packages = inputs.nixpkgs-unstable.lib.unique ((import ./config/packages.nix)/* ++ packages-x32*/);
      hosts = builtins.map (host: (builtins.replaceStrings [ ".nix" ] [ "" ] host)) (
        builtins.attrNames (builtins.readDir (./hosts))
      );
      #pkgs-x32 = import inputs.nixpkgs-x32 { system = "x86_64-linux"; };

      pkgs = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
          };
        }) targets
      );
      pkgs-broken = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
          };
        }) targets
      );
      pkgs-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowUnsupportedSystem = true;
          };
        }) targets
      );
      pkgs-broken-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
        }) targets
      );
    in
    {
      packages = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs.${target}.${package};
            }) packages
          );
        }) targets
      )) /* // {
        x86_64-linux = {
          default = pkgs-x32.linuxPackages;
        } // (builtins.listToAttrs (
          map (package: {
            name = package;
            value = pkgs-x32.${package};
          }) packages-x32
        ));
      } */;

      packages-broken = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-broken.${target}.${package};
            }) packages
          );
        }) targets
      );

      packages-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-unsupported.${target}.${package};
            }) packages
          );
        }) targets
      );

      packages-broken-unsupported = builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = inputs.nixpkgs-unstable.legacyPackages.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = pkgs-broken-unsupported.${target}.${package};
            }) packages
          );
        }) targets
      );

      nixosConfigurations =
        (builtins.listToAttrs (
          builtins.map (target: {
            name = target;
            value = inputs.nixpkgs-unstable.lib.nixosSystem {
              system = "${target}";
              modules = [
                ./host.nix
              ];
            };
          }) targets
        ))
        // (builtins.listToAttrs (
          builtins.concatMap (
            target:
            (builtins.map (host: {
              name = "${target}-${host}";
              value = inputs.nixpkgs-unstable.lib.nixosSystem {
                system = "${target}";
                modules = [
                  (./hosts + "/${host}.nix")
                ];
              };
            }) hosts)
          ) targets
        )) /* // {
          "x32" = inputs.nixpkgs-x32.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./host.nix
            ];
          };
        } */;

      hydraJobs = {
        inherit (self) packages;
        inherit (self) packages-broken;
        inherit (self) packages-unsupported;
        inherit (self) packages-broken-unsupported;
        nixosConfigurations =
          builtins.listToAttrs (
            map (target: {
              name = target;
              value = self.nixosConfigurations.${target}.config.system.build.toplevel;
            }) targets
          )
          // (builtins.listToAttrs (
            builtins.concatMap (
              target:
              (builtins.map (host: {
                name = "${target}-${host}";
                value = self.nixosConfigurations."${target}-${host}".config.system.build.toplevel;
              }) hosts)
            ) targets
          ));
        # x32 = self.nixosConfigurations.x32.config.system.build.toplevel;
      };
    };
}
