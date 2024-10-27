{
  description = "Simple script to force a time machine verification on a schedule via JXA";
  outputs =
    { self, nixpkgs }:
    let
      name = "verify-time-machine";
      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem =
        with nixpkgs.lib;
        f: foldAttrs mergeAttrs { } (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
    in
    eachSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.${name};
          ${name} = pkgs.writeScriptBin name (builtins.readFile ./${name}.js);
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.${name}}/bin/${name}";
        };
      }
    )
    // {
      homeManagerModules = {
        default = self.outputs.homeManagerModules.${name};
        verify-time-machine = import ./module.nix self;
      };
    };
}
