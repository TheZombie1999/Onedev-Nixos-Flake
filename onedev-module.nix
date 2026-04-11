{
  config,
  lib,
  options,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.onedev;
  opt = options.services.onedev;
in
{
  imports = [ ];

  options = {
    services.onedev = {
      enable = lib.mkEnableOption "onedev";
      installDir = lib.mkOption {
        type = lib.types.str;
        default = "/opt/onedev/";
        description = "The folder Onedev reads and writes to.";
      };
      http_host = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "The Ip-Address onedev is reachable unter.";
      };
      http_port = lib.mkOption {
        type = lib.types.port;
        default = 6610;
        description = "The Port the onedev application is reachable under.";
        apply = toString;
      };
      ssh_port = lib.mkOption {
        type = lib.types.port;
        default = 6611;
        description = "The port used for ssh access of onedev.";
        apply = toString;
      };
    };
  };

  config =
    let
      onedev = pkgs.callPackage ./onedev.nix { inherit (cfg) installDir; };
      hibernateConfig = pkgs.callPackage ./hibernate-config.nix { inherit (cfg) installDir; };
      serverConfig = pkgs.callPackage ./server-config.nix {
        inherit (cfg)
          installDir
          http_host
          http_port
          ssh_port
          ;
      };
    in
    lib.mkIf cfg.enable {

      environment.systemPackages = [ onedev ];

      fileSystems = {
        "/opt/onedev" = {
          overlay = {
            workdir = "/opt/overlay/onedev/work";
            upperdir = "/opt/overlay/onedev/upper";
            lowerdir = [
              "${hibernateConfig}"
              "${serverConfig}"
              "${onedev}"
            ];
          };
        };
      };

      systemd.services."onedev-server" = {
        enable = true;
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Environment = "PATH=${
            lib.makeBinPath [
              pkgs.toybox
              pkgs.coreutils
              pkgs.curl
              pkgs.git
              pkgs.fontconfig
              pkgs.dejavu_fonts
            ]
          }";
          Type = "simple";
          ExecStart = "${onedev}/bin/server.sh console";
          User = "root";
        };
      };
    };
}
