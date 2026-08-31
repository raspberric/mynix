# LiteLLM gateway

LiteLLM listens on `127.0.0.1:4000` and exposes the `free-coding` model alias.
It tries providers in this order:

1. Mistral Medium
2. Gemini Flash
3. Cloudflare GPT-OSS 120B
4. Groq GPT-OSS 120B
5. SambaNova GPT-OSS 120B
6. Cohere Command A
7. Z.AI GLM Flash
8. OpenRouter GLM free route

Provider credentials live in `/etc/litellm/credentials.env`. The NixOS module
creates this file with mode `0600` but never puts its contents in the Nix store.
Add any available credentials using this format:

```sh
MISTRAL_API_KEY=
GEMINI_API_KEY=
CLOUDFLARE_API_KEY=
CLOUDFLARE_ACCOUNT_ID=
GROQ_API_KEY=
SAMBANOVA_API_KEY=
COHERE_API_KEY=
ZAI_API_KEY=
OPENROUTER_API_KEY=
```

Restart the service after changing credentials:

```sh
sudo systemctl restart litellm
```

Check the gateway and its model catalog with:

```sh
systemctl status litellm
curl http://127.0.0.1:4000/health/liveliness
curl http://127.0.0.1:4000/v1/models
```

Quota exhaustion is detected reactively from provider errors. LiteLLM cannot
query a standardized remaining-free-quota API. A deployment that fails is
cooled down for five minutes before LiteLLM tries it again.
