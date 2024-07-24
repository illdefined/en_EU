{
  description = "Custom locale";
  outputs = { self, ... }: {
    overlays.default = final: prev: {
      glibcLocales = prev.glibcLocales.overrideAttrs (base: {
        postPatch = base.postPatch + ''
          cp ${prev.lib.escapeShellArg ./en_EU} localedata/locales/en_EU
          echo 'en_EU.UTF-8/UTF-8 \' >>localedata/SUPPORTED
        '';
      });
    };

    nixosModules.default = { lib, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
      i18n.defaultLocale = lib.mkDefault "en_EU.UTF-8";
    };
  };
}
