# COD1.6X dedicated server image: Call of Duty 1.5 Linux server + cod1plus.so + PAM.
#
# The game itself is NOT in this repository (Activision's files): put yours in gamefiles/
# before building - see gamefiles/README.md. Everything else is fetched and checked here.
#
# i386 userland: cod_lnxded, game.mp.i386.so and cod1plus.so are 32-bit ELF. It runs on any
# x86_64 Docker host (Linux, or Windows / macOS-Intel with Docker Desktop).
FROM i386/debian:bookworm-slim

# cod_lnxded dates from 2004 and links libstdc++.so.5 (GCC 3 ABI); no current Debian ships
# it, the package comes from the archive. curl stays: cod1plus.so shells out to it (client
# version gate, FPSChallenge), and it fetches PAM below.
ARG LIBSTDCPP5=http://archive.debian.org/debian/pool/main/g/gcc-3.3/libstdc++5_3.3.6-30_i386.deb
RUN apt-get update \
 && apt-get install -y --no-install-recommends libstdc++6 zlib1g curl ca-certificates \
 && curl -fsSL -o /tmp/libstdc++5.deb "$LIBSTDCPP5" \
 && dpkg -i /tmp/libstdc++5.deb \
 && rm -f /tmp/libstdc++5.deb \
 && rm -rf /var/lib/apt/lists/* \
 && ldconfig -p | grep -q "libstdc++\.so\.5"

# PAM, from the manifest the COD1.6X clients install from (every file sha256-checked), so a
# server built here always matches what the players' "INSTALL / UPDATE PAM" button gives.
# Its own layer: ~190 MB downloaded once, not on every rebuild.
ARG PAM_MANIFEST=https://raw.githubusercontent.com/cod1plus/cod1pluspam/main/pam.manifest
COPY docker/fetch_pam.sh /usr/local/bin/fetch_pam.sh
RUN sed -i 's/\r$//' /usr/local/bin/fetch_pam.sh \
 && chmod +x /usr/local/bin/fetch_pam.sh \
 && fetch_pam.sh "$PAM_MANIFEST" /cod1/__rPAMv115b5

# The game (your files) and optional extra maps.
COPY gamefiles/ /cod1/
COPY maps/ /cod1/__rPAMv115b5/

# cod1plus.so: gamefiles/cod1plus.so if you put one there, else the release below.
ARG COD1PLUS_URL=https://github.com/cod1plus/cod1plushookserver/releases/latest/download/cod1plus.so
COPY docker/ /opt/cod1/
RUN sed -i 's/\r$//' /opt/cod1/*.sh /opt/cod1/*.cfg \
 && chmod +x /opt/cod1/*.sh \
 && /opt/cod1/check_gamefiles.sh "$COD1PLUS_URL"

# One writable folder per server (logs, demos, archived cvars): mount a volume there.
VOLUME /data
WORKDIR /data
ENTRYPOINT ["/opt/cod1/entrypoint.sh"]
