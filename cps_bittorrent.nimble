version = "1.0.0"
author = "Gabriel Arroyo"
description = "BitTorrent client with DHT, uTP, trackers and disk storage for the CPS Nim runtime."
license = "MIT"
srcDir = "src"
skipDirs = @["tests", "examples", "benchmarks", ".github", "scripts"]

requires "nim >= 2.0.0"
requires "https://github.com/gabearro/cps-runtime#v1.0.0"
requires "https://github.com/gabearro/cps-tls#v1.0.0"

task test, "Run the project test suite":
  exec "nim c -r tests/bittorrent/test_bencode.nim"
  exec "nim c -r tests/bittorrent/test_metainfo.nim"
  exec "nim c -r tests/bittorrent/test_peer_protocol.nim"
  exec "nim c -r tests/bittorrent/test_extensions.nim"
  exec "nim c -r tests/bittorrent/test_dht_validation.nim"

