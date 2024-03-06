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
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          pkg-config
          gtk4
          gtk4-layer-shell
          webkitgtk_6_0

          toolchain
        ];

        shellHook = ''
	  export GIO_EXTRA_MODULES="$GIO_EXTRA_MODULES:${pkgs.glib-networking}/lib/gio/modules"
        '';
      };
    });
}
