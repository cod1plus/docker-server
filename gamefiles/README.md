# gamefiles/

Your copy of the Call of Duty 1.5 **Linux dedicated server**. Nothing in this folder is ever
committed (see `.gitignore`); it is copied into the image by `docker compose build`.

```
gamefiles/
  cod_lnxded                 the Linux server binary (1.5)
  cod1plus.so                optional - downloaded from its GitHub release if absent
  main/
    game.mp.i386.so          the Linux game module (from the Linux server package)
    pak0.pk3 ... pak6.pk3
    pak8.pk3 pak9.pk3 paka.pk3 pakb.pk3
    localized_english_pak*.pk3   (any language works)
```

- `pak*.pk3` and `localized_*.pk3` are the ones of any Call of Duty 1.5 install (the `Main`
  folder of the game on Windows): same files on both systems.
- `cod_lnxded` and `game.mp.i386.so` come from the 1.5 Linux dedicated server package; they are
  not part of a Windows install.
- Nothing else: PAM is downloaded by the build (the exact files the COD1.6X clients install), and
  extra maps go in `../maps/`.

The build stops with the list of what is missing if a file is not there.
