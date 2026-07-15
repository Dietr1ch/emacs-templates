{
  lib,
  fetchCrate,
	rustPlatform,
  nix-update-script,
  testers,
}:

rustPlatform.buildRustPackage rec {
  pname = "$0";
  version = "$1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchCrate {
    inherit version;
    crateName = "$0";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    $3
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = $0; };
  };

  meta = {
    description = "$4";
    homepage = "https://github.com/$1/$0";
    changelog = "https://github.com/$1/$0/releases/tag/v${version}";
    license = lib.licenses.$5;
    maintainers = with lib.maintainers; [ Dietr1ch ];
    mainProgram = "$0";
  };
}