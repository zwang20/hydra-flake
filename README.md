# hydra-flake
packages for hydra to build, in flake form

http://hydra.home.arpa:3000/project/nixpkgs

## test eval
```bash
nix-instantiate release.nix --arg system \"i686-linux\" --arg nixpkgs "import <nixpkgs>" --eval -A i686-linux
```

## import
```python
[print('"' + i.split('.', 2)[2] + '"') for i in x.split()]
```

## sort
```bash
sort config/packages.nix | uniq | grep -v -F '[' | grep -v -F ']' > tmp; { echo '[' ; cat tmp; echo ']'; } > config/packages.nix; rm tmp
```
