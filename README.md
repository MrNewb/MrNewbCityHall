# MrNewbCityHall

City hall NPCs for ID replacements, walk-up jobs, and applications with optional Discord webhooks.

[Documentation](https://mrnewb.github.io/docs/mrnewbcityhall) · [Discord](https://discord.gg/mrnewbscripts)

## Install

Needs [ox_lib](https://github.com/overextended/ox_lib) and [Newb_Bridge](https://github.com/MrNewb/Newb_Bridge).

```cfg
ensure ox_lib
ensure Newb_Bridge
ensure MrNewbCityHall
```

## Config

| File | Realm | Contents |
|---|---|---|
| `configs/cityhall.lua` | shared | Locations, ID price, interact distance, application cooldown, available jobs and grades |
| `configs/applications.lua` | shared | Application questions per job |
| `configs/webhooks.lua` | **server only** | Per-job Discord webhook URLs (empty string = submit rejected; the application still appears in the menu) |

Webhook URLs never leave the server. Submits are rejected until a valid Discord webhook URL is set for that job (`https://discord.com/api/webhooks/...`, also `discordapp.com` / PTB / Canary).

Details and examples: [docs](https://mrnewb.github.io/docs/mrnewbcityhall).
