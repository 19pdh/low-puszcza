{
  description = "19 PDH Puszcza low-tech site";
  inputs.nur.url = github:nix-community/NUR;
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nur, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
    kronika = let
      kronika_json = pkgs.lib.importJSON ./kronika.json;
    in pkgs.fetchFromGitHub {
      repo = "kronika";
      owner = "19pdh";
      rev = kronika_json.rev;
      sha256 = kronika_json.sha256;
    };


    low-puszcza = pkgs.stdenv.mkDerivation {
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


  in {
    defaultPackage = low-puszcza;
    packages.low-puszcza = low-puszcza;
  });
}
