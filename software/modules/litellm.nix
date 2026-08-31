{config, ...}: let
  credentialsFile = "/etc/litellm/credentials.env";

  deployment = modelName: model: apiKey: {
    model_name = modelName;
    litellm_params = {
      inherit model;
      api_key = "os.environ/${apiKey}";
    };
  };
in {
  services.litellm = {
    enable = true;
    host = "127.0.0.1";
    port = 4000;
    environmentFile = credentialsFile;
    openFirewall = false;

    # Empty defaults let the gateway start before credentials are installed.
    # A provider with no key fails over to the next configured deployment.
    environment = {
      MISTRAL_API_KEY = "";
      GEMINI_API_KEY = "";
      CLOUDFLARE_API_KEY = "";
      CLOUDFLARE_ACCOUNT_ID = "";
      GROQ_API_KEY = "";
      SAMBANOVA_API_KEY = "";
      COHERE_API_KEY = "";
      ZAI_API_KEY = "";
      OPENROUTER_API_KEY = "";
    };

    settings = {
      model_list = [
        (deployment "free-coding" "mistral/mistral-medium-latest" "MISTRAL_API_KEY")
        (deployment "free-coding-02-gemini" "gemini/gemini-3.7-flash" "GEMINI_API_KEY")
        ((deployment "free-coding-03-cloudflare" "cloudflare/@cf/openai/gpt-oss-120b" "CLOUDFLARE_API_KEY")
          // {
            litellm_params = {
              model = "cloudflare/@cf/openai/gpt-oss-120b";
              api_key = "os.environ/CLOUDFLARE_API_KEY";
              account_id = "os.environ/CLOUDFLARE_ACCOUNT_ID";
            };
          })
        (deployment "free-coding-04-groq" "groq/openai/gpt-oss-120b" "GROQ_API_KEY")
        (deployment "free-coding-05-sambanova" "sambanova/gpt-oss-120b" "SAMBANOVA_API_KEY")
        (deployment "free-coding-06-cohere" "cohere_chat/command-a-03-2025" "COHERE_API_KEY")
        (deployment "free-coding-07-zai" "zai/glm-4.7-flash" "ZAI_API_KEY")
        (deployment "free-coding-08-openrouter" "openrouter/z-ai/glm-5.2:free" "OPENROUTER_API_KEY")
      ];

      router_settings = {
        num_retries = 0;
        allowed_fails = 1;
        cooldown_time = 300;
        fallbacks = [
          {
            "free-coding" = [
              "free-coding-02-gemini"
              "free-coding-03-cloudflare"
              "free-coding-04-groq"
              "free-coding-05-sambanova"
              "free-coding-06-cohere"
              "free-coding-07-zai"
              "free-coding-08-openrouter"
            ];
          }
        ];
      };

      litellm_settings = {
        drop_params = true;
        request_timeout = 120;
      };
    };
  };

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
