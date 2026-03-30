{
  pkgs,
  lib,
  ...
}:

let
  project_name = "test_project";
  pg_port = 35432;
  vk_port = 36379;
in
{
  env = {
    "PROJECT_NAME" = project_name;
    "PGPORT" = pg_port;
    "VALKEYCLI_PORT" = vk_port;
  }; # ..env
  dotenv.enable = true;

  # https://devenv.sh/packages/
  packages = with pkgs; [
    hunspell
    hunspellDicts.en_GB-large

    # Git
    git

		# Rust
		cargo-deny
    diesel-cli

    # Serving
    static-web-server
  ]; # ..packages

  # https://devenv.sh/languages/
  languages = {
    rust = {
      enable = true;
      mold.enable = true;
    }; # ..languages.rust
  }; # ..languages

  # https://devenv.sh/services/
  services = {
    # https://devenv.sh/services/postgres/
    postgres = {
      enable = true;

      listen_addresses = "127.0.0.1";
      port = pg_port;

      settings = {
        log_connections = true;
        log_statement = "all";
        logging_collector = true;
        log_disconnections = true;
        log_destination = lib.mkForce "syslog";
      };

      # https://devenv.sh/services/postgres/#servicespostgresextensions
      extensions = exts: [
        exts.pg_uuidv7
        exts.pgaudit
        exts.pgvector
        exts.postgis
      ];

      initialScript = ''
        create extension if not exists pg_uuidv7;
        create extension if not exists pgaudit;
        create extension if not exists pgvector;
        create extension if not exists postgis;
      '';

      initdbArgs = [
        "--locale=C"
        "--encoding=UTF8"
        "--data-checksums"
      ];

      initialDatabases = [
        {
          name = project_name;
        }
      ];
    }; # ..services.postgres

    # https://devenv.sh/services/redis/
    redis = {
      enable = true;
      package = pkgs.valkey;

      bind = "127.0.0.1";
      port = vk_port;
    }; # ..services.redis
  }; # ..services

  treefmt = {
    enable = true;

    # Configuration: .treefmt.toml
    config = {
      programs = {
        jsonfmt.enable = true;
        nixfmt.enable = true;
        rustfmt.enable = true;
        sqruff.enable = true;
      };
    };
  }; # ..treefmt

  git-hooks = {
    # https://devenv.sh/reference/options/#git-hookshooks
    hooks = {
      # Shell
      shellcheck.enable = true;
      check-executables-have-shebangs.enable = true;
      check-symlinks.enable = true;

      # Misc
      cspell.enable = true;
      keep-sorted.enable = true;

      treefmt = {
        enable = true;
      };

      # Git
      check-merge-conflicts.enable = true;

      # JSON
      check-json.enable = true;

      # Rust
      cargo-check.enable = true;
      cargo-deny = {
        name = "cargo-deny";
        description = "Run `cargo deny check`.";
        entry = "${pkgs.cargo-deny}/bin/cargo-deny check";
        files = "^Cargo.*";
        pass_filenames = false;

        enable = true;
      };
      clippy.enable = true;
      clippy.packageOverrides.cargo = pkgs.cargo;
      clippy.packageOverrides.clippy = pkgs.clippy;
      clippy.settings.allFeatures = true;
    }; # ..git-hooks.hooks
  }; # ..git-hooks
}