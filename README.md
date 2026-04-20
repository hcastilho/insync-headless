# insync-headless

Docker image for [Insync](https://www.insynchq.com) headless — syncs a Google Drive account to a mounted volume. Built on `ubuntu:24.04` with the official `insync-headless` apt package.

Published to `ghcr.io/hcastilho/insync-headless`.

## Usage

See [docker-compose.yml](docker-compose.yml) for an example.

## First-run auth

Insync headless requires Google account linking on first start. Start the container, then run `add-account` inside it:

```bash
docker compose up -d
docker compose exec insync insync-headless add-account -a <email> -p /data
```

Auth state persists in the `.config` bind mount — do not delete it.

## License

MIT — see [LICENSE](LICENSE).
