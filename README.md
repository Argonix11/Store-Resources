# Argonix Store — game-server resources

Server-side resources that connect a game server to its **Argonix VIP Store**. When a player
buys a package, the resource for that game receives the purchased command(s) and runs them on
the server. Argonix never connects to your server — the resource reaches out to Argonix on a
timer, authenticated with your store's secret.

## Pick the folder for your game

| Game | Folder | How it works |
|------|--------|--------------|
| **FiveM** | [`fivem/argonix-store`](fivem/argonix-store) | The resource **pulls** purchased commands from Argonix and runs them in the server console. |
| **Minecraft** | — (no resource needed) | Minecraft servers are driven directly by Argonix over the Pterodactyl console; there is nothing to install. |

Each game folder has its own `README.md` with install steps.

## Where do I get my store secret?

In your Argonix dashboard: **VIP Store → your store → FiveM server connection**. Copy the secret
and the API URL from there into your server config as the game's README describes. Keep the
secret private; if it leaks, regenerate it in the dashboard and update your config.
