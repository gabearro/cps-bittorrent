# cps-bittorrent

BitTorrent client with DHT, uTP, trackers and disk storage for the CPS Nim runtime.

## Install

```sh
nimble install https://github.com/gabearro/cps-bittorrent@#v1.0.0
```

```nim
import cps/bittorrent
```

Dependencies are resolved automatically by Nimble: `cps-runtime`, `cps-tls`.

## Development

```sh
nimble install -d -y
nimble test
```

This repository was extracted from [gabearro/cps-runtime](https://github.com/gabearro/cps-runtime) with its relevant Git history preserved.

## License

MIT

