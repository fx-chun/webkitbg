{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, fenix, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      toolchain = fenix.packages.${system}.fromToolchainFile {
        file = ./rust-toolchain.toml;
        sha256 = "sha256-e4mlaJehWBymYxJGgnbuCObVlqMlQSilZ8FljG9zPHY=";
      };

      webkitbgDeps = with pkgs; [
        gtk4
        gtk4-layer-shell
        webkitgtk_6_0
      ];
    in {
      packages.default = (pkgs.makeRustPlatform {
        cargo = toolchain;
        rustc = toolchain;
      }).buildRustPackage {
        pname = "webkitbg";
        version = "0.1.0";

        nativeBuildInputs = with pkgs; [ pkg-config wrapGAppsHook ];
        buildInputs = webkitbgDeps;

        src = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ] ./.;

        cargoLock.lockFile = ./Cargo.lock;
      };

      devShells.default = pkgs.mkShell {
        packages = webkitbgDeps ++ [
          pkgs.pkg-config
          toolchain
        ];

        shellHook = ''
	  export GIO_EXTRA_MODULES="$GIO_EXTRA_MODULES:${pkgs.glib-networking}/lib/gio/modules"
        '';
      };
    });
}
