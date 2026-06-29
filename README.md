# hydra-flake
packages for hydra to build, in flake form

```bash
nix-instantiate release.nix --arg system \"i686-linux\" --arg nixpkgs "import <nixpkgs>" --eval -A i686-linux
```
