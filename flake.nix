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
      _targets = [
        #"x86_64-linux"
        "i686-linux"
        #"aarch64-linux"
        "armv7l-linux"
        "armv6l-linux"
        "powerpc64-linux"
      ];
      _marches = [
        "x86-64-v3"
        "skylake"
      ];
      _packages = import ./config/packages.nix;
      _python-packages = import ./config/python-packages.nix;
      _hosts = builtins.map (host: (builtins.replaceStrings [ ".nix" ] [ "" ] host)) (
        builtins.attrNames (builtins.readDir (./hosts))
      );
      _pkgs = (builtins.listToAttrs (
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
      packages = (builtins.listToAttrs (
        map (target: {
          name = target;
          value = {
            default = _pkgs.${target}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs.${target}.${package};
            }) _packages
          );
        }) _targets
      ))
      // (builtins.listToAttrs (
        map (march: {
          name = march;
          value = {
            default = _pkgs.${march}.hello;
          }
          // builtins.listToAttrs (
            map (package: {
              name = package;
              value = _pkgs.${march}.${package};
            }) _packages
          );
        }) _marches
      ));

      python-packages = builtins.listToAttrs (
        map (target: {
          name = target;
          value = builtins.listToAttrs ( map (
            package: {
              name = package;
              value = _pkgs.${target}.python3.withPackages (python-pkgs: [ python-pkgs.${package} ]);
            }
          ) _python-packages );
        }) _targets
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
          }) _targets
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
            }) _hosts)
          ) _targets
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
        inherit (self) python-packages;
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
