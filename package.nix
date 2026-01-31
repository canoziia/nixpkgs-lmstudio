{
  lib,
  stdenv,
  callPackage,
  ...
}@args:
let
  pname = "lmstudio";

  version_aarch64-darwin = "0.4.1-1";
  hash_aarch64-darwin = "sha256-rVmBKDejuOYprHbQ/UhiAm8PfVgGoPTXbx1Qkdi4j+g=";
  version_x86_64-linux = "0.4.1-1";
  hash_x86_64-linux = "sha256-0Y4XjK3vfWeY8Z5tQfM6KX4modKFCRy8MNqCUtGKRvA=";
  version_aarch64-linux = "0.4.1-1";
  hash_aarch64-linux = "sha256-4feNNyCeUE72u5KEJfTQdfxBbKhfwtihqNlpQGD2RMU=";

  meta = {
    description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
    homepage = "https://lmstudio.ai/";
    license = lib.licenses.unfree;
    mainProgram = "lm-studio";
    maintainers = with lib.maintainers; [ crertel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = stdenv.hostPlatform.isDarwin; # Upstream issue: https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/347
  };
in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit pname meta;
    passthru.updateScript = ./update.sh;
    version = version_aarch64-darwin;
    url =
      args.url
        or "https://installers.lmstudio.ai/darwin/arm64/${version_aarch64-darwin}/LM-Studio-${version_aarch64-darwin}-arm64.dmg";
    hash = args.hash or hash_aarch64-darwin;
  }
else
  let
    config =
      if stdenv.hostPlatform.isAarch64 then
        {
          version = version_aarch64-linux;
          hash = hash_aarch64-linux;
          arch = "arm64";
        }
      else
        {
          version = version_x86_64-linux;
          hash = hash_x86_64-linux;
          arch = "x64";
        };
  in
  callPackage ./linux.nix {
    inherit pname meta;
    passthru.updateScript = ./update.sh;
    version = config.version;
    url =
      args.url
        or "https://installers.lmstudio.ai/linux/${config.arch}/${config.version}/LM-Studio-${config.version}-${config.arch}.AppImage";
    hash = args.hash or config.hash;
  }
