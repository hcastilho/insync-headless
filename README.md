# insync-headless

Docker image for [Insync](https://www.insynchq.com) headless — syncs a Google Drive account to a mounted volume. Built on `ubuntu:24.04` with the official `insync-headless` apt package.

Published to `ghcr.io/hcastilho/insync-headless`.

## Usage

```yaml
services:
  insync:
    image: ghcr.io/hcastilho/insync-headless:latest
    restart: unless-stopped
    volumes:
      - insync-data:/root/.config/Insync
      - /path/to/sync/target:/data:rw

volumes:
  insync-data:
```

## First-run auth

Insync headless requires interactive Google account linking on first start. Run once on the host to link the account:

```bash
docker compose run --rm insync insync-headless start
# in another shell, attach and run:
docker compose exec insync insync-headless add-account -a <email> -p /data
```

Auth state persists in the `insync-data` volume — do not delete it.

## License

MIT — see [LICENSE](LICENSE).
