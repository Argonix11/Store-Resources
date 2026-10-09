# Argonix VIP Store — FiveM resource

This small resource connects your FiveM server to your Argonix VIP Store. When a player buys a
package, this resource **pulls** the purchased command(s) from Argonix and runs them in your
server console. Argonix never connects to your server — your server reaches out to Argonix on a
timer, authenticated with your store's secret.

## Install

1. Copy the `argonix-store` folder into your server's `resources/` directory
   (e.g. `resources/[argonix]/argonix-store`).

2. In your `server.cfg` add:

   ```cfg
   ensure argonix-store

   # From your Argonix store dashboard → FiveM server connection:
   set argonix_store_secret "YOUR-STORE-SECRET"

   # Let the resource run console commands:
   add_ace resource.argonix-store command allow
   ```

3. (Optional) Only if your Argonix instance is on a different host than the default, also set:

   ```cfg
   set argonix_store_url "https://your-argonix-host/api/store/gameserver"
   ```

4. Restart the server (or `ensure argonix-store`). You should see:

   ```
   [argonix-store] started — polling https://argonix.dev/api/store/gameserver
   ```

## How your package commands should look

Write your package commands in the Argonix dashboard exactly as you would type them in the FiveM
server console. Use `{player}` where the buyer's identifier should go — the buyer enters their
FiveM/Steam identifier (e.g. `steam:110000112345678`) at checkout. Examples:

```
add_principal identifier.{player} group.vip
setjob {player} police 0
```

## Security notes

- Keep `argonix_store_secret` private. Anyone with it can read your store's command queue. If it
  leaks, regenerate it in the Argonix dashboard and update `server.cfg`.
- The resource only ever runs commands your store queued for it; it does not accept any inbound
  connection.
