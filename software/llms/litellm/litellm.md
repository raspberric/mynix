# LiteLLM gateway

LiteLLM listens on `127.0.0.1:4000`, is available at
`http://litellm.localhost:4000`, and exposes the `free-coding` model alias. The
service does not start automatically. It tries providers in this order:

1. OpenRouter GLM free route
2. Z.AI GLM Flash
3. Gemini Flash
4. Cloudflare GPT-OSS 120B
5. Groq GPT-OSS 120B
6. SambaNova GPT-OSS 120B
7. Cohere Command A
8. Mistral Medium

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

Start and stop the gateway manually with:

```sh
sudo systemctl start litellm
sudo systemctl stop litellm
```

Restart it after changing credentials with `sudo systemctl restart litellm`.

Check the gateway and its model catalog with:

```sh
systemctl status litellm
curl http://litellm.localhost:4000/health/liveliness
curl http://litellm.localhost:4000/v1/models
```

Quota exhaustion is detected reactively from provider errors. LiteLLM cannot
query a standardized remaining-free-quota API. A deployment that fails is
cooled down for five minutes before LiteLLM tries it again.
