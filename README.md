# docker-server

Run **COD1.6X** servers (Call of Duty 1.5 + [cod1plus.so](https://github.com/cod1plus/cod1plushookserver)
+ [PAM](https://github.com/cod1plus/cod1pluspam)) in Docker - for a LAN party, as many as you want,
on Windows or Linux. One image, one block per server in `docker-compose.yml`.

## What you need

- **Docker**: Docker Desktop on Windows (WSL 2 backend, Linux containers - the default) or
  Docker Engine + the compose plugin on Linux. Any x86_64 machine.
- **Your game files** - see [`gamefiles/README.md`](gamefiles/README.md): the Call of Duty 1.5
  Linux dedicated server (`cod_lnxded`, `main/game.mp.i386.so`) and the `pak*.pk3` of the game.
  They are never committed to this repository.
- **`cod1plus.so`** in `gamefiles/` (the COD1.6X server module). If it is absent the build
  tries its latest GitHub release.

PAM is downloaded by the build, from the same manifest the COD1.6X clients install from, and
every file is sha256-checked - so the servers always run exactly what the players have.

## Start

```sh
git clone https://github.com/cod1plus/docker-server
cd docker-server
# copy your files into gamefiles/ (see gamefiles/README.md), then:
docker compose up -d --build
```

Two servers are now up: **UDP 28960** (S&D, `COD1.6X LAN #1`) and **UDP 28961**. Players
connect with `/connect <ip of this machine>:28960`. The first build downloads ~200 MB (PAM)
and copies the game into the image; the next ones are cached.

## More servers

Copy a block in `docker-compose.yml`, then change its name, `container_name`, `PORT` (and the
same number in `ports`) and the volume name - that is the whole procedure:

```yaml
  server3:
    <<: *cod1
    container_name: cod1-server3
    ports:
      - "28962:28962/udp"
    environment:
      PORT: 28962
      SV_HOSTNAME: "COD1.6X LAN #3"
      GAMETYPE: dm
      MAP: mp_dawnville
      PAM_MODE: pub
    volumes:
      - ./servers:/servers:ro
      - server3:/data
```

and add `server3:` under `volumes:` at the bottom. Then `docker compose up -d server3`.

Every setting (hostname, gametype, map, rotation, passwords, PAM mode, sv_fps, LAN or internet)
is listed at the top of `docker-compose.yml`. Anything else goes in a `.cfg` in `servers/`,
named by `EXTRA_CFG` and executed last (see `servers/server1.cfg`). A `competitive.cfg` or
`ruleset.txt` in `servers/` is picked up by every server (cod1plus.so options, see its README).

## Everyday use

| | |
|---|---|
| logs of a server | `docker compose logs -f server1` |
| its console | `docker attach cod1-server1` - type commands; **Ctrl+P then Ctrl+Q** to leave it running |
| rcon in game | `/rconPassword <RCON_PASSWORD>` then `/rcon map mp_carentan` |
| restart / stop | `docker compose restart server1` / `docker compose down` |
| after changing gamefiles/ or maps/ | `docker compose up -d --build` |
| update PAM | `docker compose build --no-cache` then `docker compose up -d` |

Logs, demos and archived cvars live in one Docker volume per server (`server1`, `server2`...),
kept across restarts and `down`. `docker compose down -v` deletes them.

## Ready-made LAN package (Windows)

For a LAN organiser who should not have to build anything: one machine with the game files
builds the image once and exports it with the `lan/` folder.

```powershell
powershell -ExecutionPolicy Bypass -File tools\make-lan-package.ps1 -Context C:\cod1-lan-build -Out C:\cod1-lan
```

`-Context` is this repository with `gamefiles/` filled (a copy outside OneDrive is better for
the ~1.2 GB of paks). `C:\cod1-lan` then holds `cod1-lan-<tag>.tar` (the whole image: game,
official PAM, cod1plus.so), `.env` naming it, and the French one-click scripts:
`DEMARRER.bat` (starts Docker Desktop if needed, loads the image the first time, starts the
servers, prints the machine's LAN address), `ARRETER.bat`, `CONSOLE.bat`, `LOGS.bat`,
`OUVRIR-PORTS-ADMIN.bat` (Windows firewall, UDP 28960-28969) and `REPARER-DOCKER.bat` (Docker
Desktop that no longer starts because Windows cannot delete the sockets it left behind:
`...\dockerInference` / `docker-secrets-engine\engine.sock: The file cannot be accessed by the
system`). See `lan/LISEZMOI.txt`. The image contains the game's files: share it only between
people who own the game.

## LAN notes

- `DEDICATED: 1` (the default) is a LAN server: no internet master, and players on a LAN
  address are not rate limited. Use `DEDICATED: 2` plus masters in your `EXTRA_CFG` for an
  internet server.
- The in-game **LAN tab** finds servers by broadcast on ports 28960-28963. Docker's port
  publishing does not forward broadcasts: on Windows, players connect by IP (or add the server
  to their favourites). On Linux you can add `network_mode: host` to a server (and remove its
  `ports:`) to make it appear in the LAN tab.
- Windows may ask whether "Docker Desktop Backend" can accept connections: allow it on
  private networks.
- Extra maps: drop the pk3s in `maps/` and rebuild. Players without them download them from
  the server on connect.

## Troubleshooting

- **Build stops with `gamefiles/ is incomplete`**: it lists the missing files.
- **`no cod1plus.so`**: put `cod1plus.so` in `gamefiles/`, or build with
  `--build-arg COD1PLUS_URL=<url of a cod1plus.so>`.
- **Nobody can join**: check the port is published (`docker compose ps`) and reachable
  (firewall), and that players run COD1.6X with PAM installed (the PAM button of the client).
