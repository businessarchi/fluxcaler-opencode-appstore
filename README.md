# fluxcaler-opencode-appstore

App-store Runtipi custom qui expose une app : **`fluxcaler-opencode`** — OpenCode HTTP API + proxy dario pour utiliser un abonnement Claude Pro/Max comme backend programmatique.

Conçu pour s'intégrer à la stack Fluxcaler (cf [`pontoizeau-lab/fluxcaler-appstore`](https://github.com/pontoizeau-lab/fluxcaler-appstore)). Ce repo est temporaire : à terme, l'app sera fusionnée dans l'app-store de David.

## Ajouter ce store à ton instance Runtipi

1. Va dans **Runtipi UI → Settings → App Stores → Add App Store**
2. URL : `https://github.com/businessarchi/fluxcaler-opencode-appstore`
3. Branch : `main`
4. Valide → Runtipi pull le repo et l'app `fluxcaler-opencode` apparaît dans le catalogue

## Installer l'app

1. Dans Runtipi UI → Apps → cherche **OpenCode + dario** → Install
2. Champ **Modèle Claude par défaut** : laisse `anthropic/claude-sonnet-4-6` ou change
3. L'app démarre. Le port HTTP `4096` (interne) est mappé à un port host alloué par Runtipi.

## Login OAuth dario (obligatoire au premier run)

```bash
docker exec -it fluxcaler-opencode dario login --manual
```

Ouvre l'URL affichée dans ton navigateur, autorise avec un compte **Claude Pro ou Max** (PAS une API key Anthropic), colle le code de retour. Les creds persistent dans le volume Tipi.

## Test depuis le VPS

```bash
curl http://localhost:<APP_PORT>/health
```

## Appel depuis n8n (même VPS Runtipi)

Node HTTP Request :
- URL : `http://fluxcaler-opencode:4096/v1/messages` (résolution par nom de service Docker)
- Headers : `Content-Type: application/json`, `anthropic-version: 2023-06-01`, `x-api-key: dario`
- Body : `{ "model": "claude-sonnet-4-6", "messages": [...], "max_tokens": 4096 }`

Le `model` dans le body **surcharge** le défaut configuré à l'install. Tu peux donc choisir Sonnet, Opus 4.6, Opus 4.7, Haiku, etc. par requête.

## Risque ToS Anthropic — à lire

dario fait passer un abonnement consumer Pro/Max pour du Claude Code officiel afin d'être facturé sur le quota subscription au lieu du pool Agent SDK séparé (qui bascule le 15 juin 2026). Ce pattern viole explicitement la page Legal d'Anthropic du 20 février 2026. Anthropic peut **bannir le compte Claude** utilisé. Recommandations :

- Utilise un compte secondaire dédié (pas ton compte principal de travail)
- Pour de la production multi-clients ou un fort volume, bascule sur une **vraie API key Platform** (`console.anthropic.com`) au lieu de dario
- Cette app est utile pour du dev/expérimentation, pas pour scale prod ToS-safe

## Roadmap

- [ ] Tester sur einvest Runtipi
- [ ] Logo Fluxcaler-cohérent (placeholder pour v1)
- [ ] Image Docker pré-buildée pushée sur ghcr.io (pour éviter le build à chaque install)
- [ ] Auth token Bearer optionnel sur opencode serve (si besoin d'exposer au-delà du Docker network)
- [ ] Transfert vers `pontoizeau-lab/fluxcaler-appstore` quand David revient de congés
