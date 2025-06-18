{ inputs, ... }:
{
  imports = [ inputs.files.flakeModules.default ];

  perSystem = psArgs: {
    treefmt.projectRoot = inputs.files;
    files.gitToplevel = inputs.files;
    make-shells.default.packages = [ psArgs.config.files.writer.drv ];
  };
}
