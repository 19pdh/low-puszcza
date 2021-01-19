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
      sha256 = "1pafahvq8xhpba2hgpipkbnhjr3j9zchnxfq4pnxqvidwz5rqr51";
    };

    md2saait = pkgs.stdenv.mkDerivation {
      name = "md2saait";
      src = ./md2saait;
      installPhase = ''
        mkdir -p $out/bin
        cp ./* $out/bin
        sed -i 's:yq:${pkgs.yq}/bin/yq:g' $out/bin/frontmatter2cfg
      '';
    };

  in {
    defaultPackage.${system} = self.packages.${system}.low-puszcza;

    packages.${system}.low-puszcza = pkgs.stdenv.mkDerivation {
      name = "low-puszcza";
      src = self;
      nativeBuildInputs = with pkgs; [
        md2saait
        zip
        pandoc
        nur.repos.pn.saait
      ];

      buildPhase = ''
        cp ${kronika}/wpisy wpisy -r
        for f in `find wpisy -name *.md`; do
          name=$(basename $f .md)
          date=$(getdate $f)
          frontmatter2cfg $f > pages/$date_$name.cfg
          pandoc $f > pages/$date_$name.html
        make
      '';

      installPhase = ''
        cp -r output $out
      '';
    };

  };
}
