# OpenCode + dario

App Runtipi qui expose l'API HTTP d'OpenCode (`opencode serve`) en utilisant un abonnement Claude Pro/Max via le proxy local **dario**. Pensé pour être appelé depuis n8n ou n'importe quel orchestrateur tournant sur le même réseau Docker Tipi.

## Architecture

```
┌─ container fluxcaler-opencode ─────────┐
│  dario proxy   (background, :3456)     │
│  opencode serve (foreground, :4096)    │
└────────────────────────────────────────┘
         ↑
   tipi_main_network
         ↑
    n8n / autres apps Tipi
```

## Premier lancement — login dario obligatoire

Après l'installation, le conteneur tourne mais dario n'a pas de credentials Anthropic. Il faut faire le login OAuth :

```bash
docker exec -it fluxcaler-opencode dario login --manual
```

Le terminal affiche une URL d'autorisation. Ouvre-la dans ton navigateur, autorise avec ton compte Claude **Pro ou Max** (pas API key — c'est OAuth user), puis colle le code de retour dans le terminal.

Les credentials sont stockées dans le volume `${APP_DATA_DIR}/data/dario` et survivent aux restarts.

## Appel depuis n8n (même VPS)

Node HTTP Request :
- URL : `http://fluxcaler-opencode:4096/...` (par nom de service Docker)
- ou : `http://localhost:<APP_PORT>` (par port host exposé)

## Modèle par défaut vs par requête

Le modèle par défaut est défini dans le form Tipi à l'install (`OPENCODE_DEFAULT_MODEL`). Mais le **client peut toujours surcharger** dans le body de chaque requête en passant `"model": "claude-opus-4-7"` (ou n'importe quel modèle Claude supporté).

## Risque ToS Anthropic

dario utilise un abonnement Claude Pro/Max en dehors du CLI Claude Code officiel — ce qui **viole les ToS d'Anthropic** (page Legal du 2026-02-20) et risque le **ban du compte**. Cette app est utilisable mais documentée comme telle : utilise un compte secondaire dédié, ou bascule sur une vraie API key Anthropic Platform pour la production partagée. Voir : https://github.com/askalf/dario.
