{
  description = "19 PDH Puszcza low-tech site";
  inputs.nur.url = github:nix-community/NUR;

  outputs = { self, nixpkgs, nur }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
  in {
    defaultPackage.${system} = self.packages.${system}.low-puszcza;

    packages.${system}.low-puszcza = pkgs.stdenv.mkDerivation {
      name = "low-puszcza";
      src = self;
      nativeBuildInputs = [ pkgs.zip pkgs.nur.repos.pn.saait ];

      installPhase = ''
        cp -r output $out
      '';
    };

  };
}
