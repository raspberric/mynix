{pkgs}: let
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = ["34.0.0" "33.0.0"];
    platformVersions = ["34" "33"];
    abiVersions = ["x86_64"];
    includeEmulator = true;
    includeSystemImages = true;
  };
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      nodejs_22
      yarn
      jdk17
      watchman
      android-studio
      androidSdk
    ];

    shellHook = ''
      export JAVA_HOME=${pkgs.jdk17.home}
      export ANDROID_HOME=${androidSdk}/libexec/android-sdk
      export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
      echo "React Native Dev Shell Loaded"
    '';
  }
