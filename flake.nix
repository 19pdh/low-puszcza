{
  description = "19 PDH Puszcza low-tech site";
  inputs.nur.url = github:nix-community/NUR;

  outputs = { self, nixpkgs, nur }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };

    kronika = pkgs.fetchFromGitHub {
      repo = "kronika";
      owner = "19pdh";
      rev = "master";
      sha256 = (builtins.fromJSON (builtins.readFile ./kronika.json)).sha256;
    };

  in {
    defaultPackage.${system} = self.packages.${system}.low-puszcza;

    packages.${system}.low-puszcza = pkgs.stdenv.mkDerivation {
      name = "low-puszcza";
      src = self;
      nativeBuildInputs = [
        pkgs.zip
        pkgs.pandoc
        pkgs.nur.repos.pn.saait
      ];

      buildPhase = ''
        sed -i 's:yq:${pkgs.yq}/bin/yq:g' ./md2saait/frontmatter2cfg
        sed -i 's:rev:${pkgs.busybox}/bin/rev:g' ./md2saait/getdate

        cp ${kronika}/wpisy wpisy -r
        mkdir pages
        for f in `find wpisy -name '*.md'`; do
          name=$(basename $f .md)
          d=$(./md2saait/getdate $f)

          ./md2saait/frontmatter2cfg $f > pages/$d-$name.cfg
          pandoc $f > pages/$d-$name.html
        done
        ls pages
        make
      '';

      installPhase = ''
        cp -r output $out
      '';
    };

  };
}
