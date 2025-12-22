{
  lib,
  stdenv,
  callPackage,
  ...
}@args:
let
  pname = "lmstudio";

  version_aarch64-darwin = "0.3.35-1";
  hash_aarch64-darwin = "sha256-iyWioENma74zWkSa+TX/P7vDByz/F8FzY+D9TC2wU6M=";
  version_x86_64-linux = "0.3.35-1";
  hash_x86_64-linux = "sha256-rZv5jpH/E7XuodJvFFfI18S+0ku7QZVR1cv/SEA4CVM=";
  version_aarch64-linux = "0.3.36-1";
  hash_aarch64-linux = "sha256-W8tLYdqW0MWHWvoDb3yiGkcsy1qW13dwxBE+Ln7F1nk=";

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
