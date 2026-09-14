{
  config,
  lib,
  ...
}: let
  credentialsFile = "/etc/litellm/credentials.env";

  deployment = order: model: apiKey: extraParams: {
    model_name = "free-coding";
    litellm_params = {
      inherit model order;
      api_key = "os.environ/${apiKey}";
    } // extraParams;
  };
in {
  networking.hosts."127.0.0.1" = ["litellm.localhost"];

  services.litellm = {
    enable = true;
    host = "127.0.0.1";
    port = 4000;
    environmentFile = credentialsFile;
    openFirewall = false;

    # Empty defaults let the gateway start before credentials are installed.
    # A provider with no key fails over to the next configured deployment.
    environment = {
      GEMINI_API_KEY = "";
      CLOUDFLARE_API_KEY = "";
      CLOUDFLARE_ACCOUNT_ID = "";
      GROQ_API_KEY = "";
      SAMBANOVA_API_KEY = "";
      ZAI_API_KEY = "";
      OPENROUTER_API_KEY = "";
    };

    settings = {
      model_list = [
        (deployment 1 "openrouter/z-ai/glm-5.2:free" "OPENROUTER_API_KEY" {})
        (deployment 2 "zai/glm-4.7-flash" "ZAI_API_KEY" {})
        (deployment 3 "gemini/gemini-3.7-flash" "GEMINI_API_KEY" {})
        (deployment 4 "cloudflare/@cf/openai/gpt-oss-120b" "CLOUDFLARE_API_KEY" {
          account_id = "os.environ/CLOUDFLARE_ACCOUNT_ID";
        })
        (deployment 5 "groq/openai/gpt-oss-120b" "GROQ_API_KEY" {})
        (deployment 6 "sambanova/gpt-oss-120b" "SAMBANOVA_API_KEY" {})
      ];

      router_settings = {
        num_retries = 2;
        allowed_fails = 2;
        cooldown_time = 300;
      };

      litellm_settings = {
        drop_params = true;
        request_timeout = 120;
      };
    };
  };

  # Keep the unit available for manual use without starting it at boot.
  systemd.services.litellm.wantedBy = lib.mkForce [];

  # This file remains mutable across rebuilds and never enters the Nix store.
  systemd.tmpfiles.rules = [
    "d /etc/litellm 0700 root root - -"
    "f ${credentialsFile} 0600 root root - -"
  ];

  assertions = [
    {
      assertion = !config.services.litellm.openFirewall;
      message = "LiteLLM must remain localhost-only because it has no client authentication.";
    }
  ];
}
