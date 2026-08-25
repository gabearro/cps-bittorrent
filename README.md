# CPS BitTorrent

A BitTorrent client implemented on the CPS runtime. This is not only a bencode
or metainfo package: it includes the peer state machines, trackers, piece
storage, discovery protocols, bandwidth controls, and the long-running client
orchestrator used by the native torrent application.

## Protocol coverage

- BEP 3 core protocol and metainfo
- BEP 5 DHT
- BEP 6 fast extension
- BEP 9/10 metadata and extension protocol
- BEP 11 peer exchange
- BEP 14 local service discovery
- BEP 15 UDP trackers
- BEP 19 web seeds
- BEP 29 uTP
- BEP 52-related validation foundations
- BEP 55 hole punching
- Magnet metadata exchange, private-torrent gating, and encrypted peer traffic

## Client behavior

- TCP and uTP peer connections
- HTTP, HTTPS, and UDP trackers
- Rarest-first piece selection and endgame racing
- Existing-file verification and multi-file storage
- DHT bootstrap/routing, PEX, LSD, web seeds, and NAT port mapping
- Per-file priority and selective download support
- Upload/download rate limits and bandwidth percentages
- Tit-for-tat choking with optimistic unchoke
- Typed event channel for UI or service integration

## Requirements

- Nim 2.0 or newer
- [cps-runtime](https://github.com/gabearro/cps-runtime)
- [cps-tls](https://github.com/gabearro/cps-tls)
- Thread-safe reference counting because the client uses the CPS MT runtime

## Install

```sh
nimble install https://github.com/gabearro/cps-bittorrent@#v1.0.0
```

The consuming project must enable the MT runtime in its `nim.cfg`:

```cfg
--threads:on
--mm:atomicArc
--deepcopy:on
```

## Inspect a torrent

```nim
import cps/bittorrent

let metainfo = parseTorrentFile("example.torrent")

echo metainfo.info.name
echo metainfo.info.totalLength
echo metainfo.info.pieceCount
echo metainfo.info.infoHashHex()
```

## Start a client

```nim
import cps
import cps/bittorrent

proc download(path: string): CpsVoidFuture {.cps.} =
  let metainfo = parseTorrentFile(path)

  var config = defaultConfig()
  config.downloadDir = "downloads"
  config.listenPort = 6881
  config.maxPeers = 80

  let client = newTorrentClient(metainfo, config)
  await client.start()

runCps(download("example.torrent"))
```

`start` runs until the client is stopped. A UI or service normally starts it
as a task, consumes `client.events`, and calls `client.stop()` during
shutdown.

## Client events

```nim
let runFuture = client.start()

while true:
  let event = await client.events.recv()
  case event.kind
  of cekProgress:
    echo event.completedPieces, " / ", event.totalPieces
    echo "peers: ", event.peerCount, ", down: ", event.downloadRate, " B/s"
  of cekCompleted:
    echo "download complete"
  of cekError:
    echo "torrent error: ", event.errMsg
  else:
    discard

await runFuture
```

## Module map

| Module | Responsibility |
| --- | --- |
| `bencode` | Bencoding parser and encoder |
| `metainfo` | Torrent and magnet metadata |
| `peer_protocol` | Wire messages and handshake |
| `pieces` | Piece/block state and scheduling |
| `storage` | Multi-file disk I/O and verification |
| `tracker` | HTTP/HTTPS/UDP announce and scrape |
| `dht` | Kademlia routing and KRPC |
| `utp` / `utp_stream` | uTP transport |
| `extensions` / `metadata` / `pex` | Extension protocol |
| `mse` | Message stream encryption |
| `client` | Long-running orchestrator |

The finished macOS application is in
[cps-torrent-app](https://github.com/gabearro/cps-torrent-app).

## Development

Read the [BitTorrent developer guide](docs/development.md) before changing public
APIs, ownership, protocol state, or execution behavior.

```sh
nimble install -d -y
nimble checkDocs
nimble docs
nimble test
```

`nimble docs` writes the generated API reference to
[`docs/api/theindex.html`](docs/api/theindex.html).

The default suite covers bencode, metainfo, peer messages, extension
negotiation, and DHT validation without joining the public swarm.

## License

MIT
