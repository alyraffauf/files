{
  perSystem =
    { pkgs, ... }:
    {
      files = {
        projectRoot = ./dir;
        files = [
          {
            path_ = "file.txt";
            drv = pkgs.writeText "file.txt" ''
              Same contents
            '';
          }
        ];
      };
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          nix flake check
          declare out
          touch "$out" 
        '';
      };
    };
}
