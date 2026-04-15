{ pkgs, system }:

let
  version = "3.9.0.2";
  sources = {
    x86_64-linux = {
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
      hash = "sha256:a69abfababda8a56969a254b09f9553a7be89ddec00d4e0fe9fd585d71a67508";
    };
    aarch64-linux = {
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-arm64.tar.gz";
      hash = "sha256:b6d21e8f9c3b15744f5a7ab40248019157ed7793875dbe0383d4c82ff572b528";
    };
    x86_64-darwin = {
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-x86_64-macOS.zip";
      hash = "sha256:b9fbceabccbc8f34ac021a50483fc32f8160568d0b4b2c22d81bb29e3054fd82";
    };
    aarch64-darwin = {
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-arm64-macOS.zip";
      hash = "sha256:6e9eca844076bcbb599bbeebbba78a70f93b5307782b85c2c272872812c88875";
    };
  };
  src = sources.${system};
in
pkgs.stdenv.mkDerivation {
  pname = "pandoc-bin";
  inherit version;
  src = pkgs.fetchurl {
    inherit (src) url hash;
  };
  nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.unzip ];
  installPhase = ''
    mkdir -p $out
    cp -r bin $out/
  '';
}
