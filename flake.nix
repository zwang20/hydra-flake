{
  inputs = {
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self, ... }@inputs:
    let
      _targets = [
        #"x86_64-linux"
        "i686-linux"
        #"aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
        "powerpc64-linux"
      ];
      _marches = [
        # "x86-64-v3"  # bootstrapping gcc does not understand
        "haswell"
        "skylake"
        "btver2"
        "znver3"
      ];
      _packages = import ./config/packages.nix;
      _python-packages = import ./config/python-packages.nix;
      _hosts = builtins.map (host: (builtins.replaceStrings [ ".nix" ] [ "" ] host)) (
        builtins.attrNames (builtins.readDir (./hosts))
      );
      _pkgs_nixos = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixos-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
        }) _targets
      ))
      // (builtins.listToAttrs (
        map (march: {
          name = march;
          value = import inputs.nixos-unstable {
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
            localSystem = {
              system = "x86_64-linux";
              gcc.arch = march;
              gcc.tune = march;
            };
          };
        }) _marches
      ));
      _pkgs_nixpkgs = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = import inputs.nixpkgs-unstable {
            system = "${target}";
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
          };
        }) _targets
      ))
      // (builtins.listToAttrs (
        map (march: {
          name = march;
          value = import inputs.nixpkgs-unstable {
            config.allowBroken = true;
            config.allowUnsupportedSystem = true;
            localSystem = {
              system = "x86_64-linux";
              gcc.arch = march;
              gcc.tune = march;
            };
          };
        }) _marches
      ));
    in
    {
      packages-nixos = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = _pkgs_nixos.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs_nixos.${target}.${package};
            }) _packages
          );
        }) _targets
      ))
      // (builtins.listToAttrs (
        map (march: {
          name = march;
          value = {
            default = _pkgs_nixos.${march}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs_nixos.${march}.${package};
            }) _packages
          );
        }) _marches
      ));

      packages-nixpkgs = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = _pkgs_nixpkgs.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs_nixpkgs.${target}.${package};
            }) _packages
          );
        }) _targets
      ))
      // (builtins.listToAttrs (
        map (march: {
          name = march;
          value = {
            default = _pkgs_nixpkgs.${march}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs_nixpkgs.${march}.${package};
            }) _packages
          );
        }) _marches
      ));

      python-packages-nixos = builtins.listToAttrs (
        map (target: {
          name = target;
          value = builtins.listToAttrs ( map (
            package: {
              name = package;
              value = _pkgs_nixos.${target}.python3.withPackages (python-pkgs: [ python-pkgs.${package} ]);
            }
          ) _python-packages );
        }) _targets
      );

      python-packages-nixpkgs = builtins.listToAttrs (
        map (target: {
          name = target;
          value = builtins.listToAttrs ( map (
            package: {
              name = package;
              value = _pkgs_nixpkgs.${target}.python3.withPackages (python-pkgs: [ python-pkgs.${package} ]);
            }
          ) _python-packages );
        }) _targets
      );

      nixosConfigurations =
        (builtins.listToAttrs (
          builtins.map (target: {
            name = target;
            value = inputs.nixos-unstable.lib.nixosSystem {
              system = "${target}";
              modules = [
                ./host.nix
              ];
            };
          }) _targets
        ))
        // (builtins.listToAttrs (
          builtins.concatMap (
            target:
            (builtins.map (host: {
              name = "${target}-${host}";
              value = inputs.nixos-unstable.lib.nixosSystem {
                system = "${target}";
                modules = [
                  (./hosts + "/${host}.nix")
                ];
              };
            }) _hosts)
          ) _targets
        )) /* // {
          "x32" = inputs.nixos-x32.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./host.nix
            ];
          };
        } */;

      hydraJobs = {
        inherit (self) packages-nixos;
        inherit (self) packages-nixpkgs;
        inherit (self) python-packages-nixos;
        inherit (self) python-packages-nixpkgs;
        nixosConfigurations =
          builtins.listToAttrs (
            map (target: {
              name = target;
              value = self.nixosConfigurations.${target}.config.system.build.toplevel;
            }) _targets
          )
          // (builtins.listToAttrs (
            builtins.concatMap (
              target:
              (builtins.map (host: {
                name = "${target}-${host}";
                value = self.nixosConfigurations."${target}-${host}".config.system.build.toplevel;
              }) _hosts)
            ) _targets
          ));
        # x32 = self.nixosConfigurations.x32.config.system.build.toplevel;
      };
    };
}
