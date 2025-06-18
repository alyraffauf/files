{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    psArgs@{ pkgs, ... }:
    let
      cfg = psArgs.config.files;
    in
    {
      options = {
        files = {
          projectRoot = lib.mkOption {
            type = lib.types.path;
            description = ''
              File paths are relative to this.
            '';
            example = "./.";
          };

          files = lib.mkOption {
            description = ''
              Files to create.
            '';
            default = [ ];
            example =
              # nix
              ''
                [
                  {
                    path_ = "README.md";
                    drv =
                      pkgs.writeText
                        "README.md"
                        # markdown
                        '''
                          # Practical Project

                          Clear documentation
                        ''';
                  }
                  {
                    path_ = ".gitignore";
                    drv =
                      pkgs.writeText ".gitignore" '''
                        result
                      ''';
                  }
                ]
              '';
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  path_ = lib.mkOption {
                    type = lib.types.singleLineStr;
                  };
                  drv = lib.mkOption {
                    description = ''
                      Out path is expected to be a file.
                      Directory out path not supported.
                      Pull request welcome!
                    '';
                    type = lib.types.package;
                  };
                };
              }
            );
          };

          writer = {
            exeFilename = lib.mkOption {
              type = lib.types.singleLineStr;
              default = "write-files";
              description = ''
                The writer executable filename.
              '';
              example = lib.literalExpression "files-write";
            };
            drv = lib.mkOption {
              description = ''
                Provides as executable that writes configured files and their contents
                to their configured paths, relative to the configured project root
                within the top-level directory of the current git repository.

                Consider including this in the project's development shell.
              '';
              type = lib.types.package;
              readOnly = true;
            };
          };
        };
      };

      config = {
        files.writer.drv = pkgs.writeShellApplication {
          name = psArgs.config.files.writer.exeFilename;
          runtimeInputs = [ pkgs.git ];
          text = lib.pipe cfg.files [
            (map (
              { path_, drv }:
              ''
                dir=$(dirname ${path_})
                mkdir -p "$dir"
                cat ${drv} > ${lib.escapeShellArg path_}
              ''
            ))
            (lib.concat [
              ''
                git_root="$(git rev-parse --show-toplevel)"
                cd "$git_root"
              ''
            ])
            lib.concatLines
          ];
        };

        checks = lib.pipe cfg.files [
          (map (
            { path_, drv }:
            {
              name = "files/${path_}";
              value =
                pkgs.runCommand "check-file-${path_}"
                  {
                    nativeBuildInputs = [ pkgs.difftastic ];
                  }
                  ''
                    difft --exit-code --display inline ${drv} ${cfg.projectRoot + "/${path_}"}
                    touch $out
                  '';
            }
          ))
          lib.listToAttrs
        ];
      };
    }
  );
}
