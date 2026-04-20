# insync-headless

Docker image for [Insync](https://www.insynchq.com) headless — syncs a Google Drive account to a mounted volume. Built on `ubuntu:24.04` with the official `insync-headless` apt package.

Published to `ghcr.io/hcastilho/insync-headless`.

## Usage

See [docker-compose.yml](docker-compose.yml) for an example.

## First-run setup

The container runs as UID 1000 (the `ubuntu` user). The host `./config` and `${VAULT_PATH}` directories must be writable by that UID:

```bash
mkdir -p ./config
sudo chown -R 1000:1000 ./config "${VAULT_PATH}"
```

Then link a Google account:

```bash
docker compose up -d
docker compose exec insync insync-headless account add -a <email> -c gd -p /data
```

Auth state persists in the `./config` bind mount — do not delete it.

## License

MIT — see [LICENSE](LICENSE).
