version = "1.0.1"
author = "Gabriel Arroyo"
description = "BitTorrent client with DHT, uTP, trackers and disk storage for the CPS Nim runtime."
license = "MIT"
srcDir = "src"
skipDirs = @["tests", "examples", "benchmarks", ".github", "scripts"]

requires "nim >= 2.0.0"
requires "https://github.com/gabearro/cps-runtime == 1.1.1"
requires "https://github.com/gabearro/cps-tls == 1.0.2"

task checkDocs, "Verify developer documentation coverage":
  exec "python3 scripts/check_dev_docs.py"

task docs, "Generate the HTML API reference":
  exec "python3 scripts/build_docs.py"

task test, "Run the project test suite":
  exec "nim c -r tests/bittorrent/test_bencode.nim"
  exec "nim c -r tests/bittorrent/test_metainfo.nim"
  exec "nim c -r tests/bittorrent/test_peer_protocol.nim"
  exec "nim c -r tests/bittorrent/test_extensions.nim"
  exec "nim c -r tests/bittorrent/test_dht_validation.nim"

task testMms, "Run BitTorrent under ARC, ORC, and AtomicARC":
  for mm in ["arc", "orc", "atomicArc"]:
    exec "nim c --compileOnly --threads:on --mm:" & mm & " src/cps/bittorrent.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/bittorrent/test_bencode.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/bittorrent/test_metainfo.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/bittorrent/test_peer_protocol.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/bittorrent/test_extensions.nim"
    exec "nim c -r --threads:on --mm:" & mm & " tests/bittorrent/test_dht_validation.nim"
