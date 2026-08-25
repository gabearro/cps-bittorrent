# BitTorrent developer guide

The package separates immutable torrent metadata, peer wire state, piece and
storage state, discovery services, and the long-running client orchestrator.
That keeps protocol helpers testable without joining a public swarm.

## Source layout

| Path | Responsibility |
| --- | --- |
| `bencode`, `metainfo` | Bencoding, torrent files, magnet metadata |
| `peer_protocol`, `peer` | Handshake, peer messages, and connection state |
| `pieces`, `storage` | Block scheduling, verification, and multi-file I/O |
| `tracker` | HTTP, HTTPS, and UDP announce/scrape |
| `dht` | Kademlia routing and KRPC |
| `utp`, `utp_stream` | uTP packet and stream transport |
| `extensions`, `metadata`, `pex` | Extension protocol, metadata, and peer exchange |
| `mse` | Message-stream encryption |
| `holepunch`, `nat`, `lsd` | Connectivity and local discovery |
| `client` | Session ownership, peer orchestration, and events |

## Data flow

Metainfo defines piece hashes and file ranges. Trackers, DHT, PEX, LSD, and
incoming sockets produce peer candidates. Peer connections exchange availability
and requests. The piece manager assigns blocks, storage persists complete data,
and verification marks a piece complete before it is announced to peers.

## Invariants

- Untrusted bencoded lengths, paths, offsets, and message sizes are bounded.
- Torrent paths cannot escape the configured download directory.
- A block belongs to one piece range and is written only inside that range.
- A piece is complete only after its hash matches metainfo.
- Private torrents do not use DHT, PEX, or LSD.
- Rate accounting records bytes once at the transport boundary.
- Peer, DHT, and tracker failures remain isolated from the client session.

## Adding protocol support

Name the BEP and keep its codec separate from client policy. Add malformed
wire cases, size boundaries, and state-transition tests. Features that discover
or announce peers must respect the private-torrent gate.

Every exported callable needs a `##` comment. Wire helpers describe their
encoding. Stateful methods describe ownership, retry/backoff, or completion.
Storage methods describe offsets and failure behavior.

## Validation

```sh
nimble checkDocs
nimble test
```

Use local peers and deterministic fixtures for the default suite. Public swarm
tests are opt-in and must not be required to validate a release.
