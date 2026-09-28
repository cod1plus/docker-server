# maps/

Optional: extra map pk3s (or any other pk3) for all the servers. They are copied next to PAM
(`__rPAMv115b5/`) when the image is built, so rebuild after adding one:

```sh
docker compose up -d --build
```

With `sv_pure 1` every player needs the same file: players who don't have it download it from
the server when they connect (`sv_allowDownload 1`). The maps of the PAM map packs are already
included and every COD1.6X client installs them with the PAM button.

pk3s load in alphabetical order: never keep two versions of the same file.
