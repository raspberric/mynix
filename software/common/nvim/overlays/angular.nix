final: prev: {
  angular-language-server = prev.angular-language-server.overrideAttrs (old: {
    version = "21.1.0";
    src = prev.fetchurl {
      name = "ng-template-21.1.0.zip";
      url = "https://github.com/angular/angular/releases/download/vsix-21.1.0/ng-template-21.1.0.vsix";
      sha256 = "c5fdaed44d334e376703f03d498a427e0fd8c87718408c7f38dfd9803a143d29";
    };
  });
}
