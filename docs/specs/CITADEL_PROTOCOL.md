# The Citadel Protocol: Offline-First & P2P Architecture

## 1. Philosophy

The "Citadel" is not a server; it is a protocol. It assumes the global internet is hostile or unavailable. It prioritizes:

- **Local Sovereignty**: Data lives on the user's device.
- **Sneakernet Sync**: USB/Local LAN propagation.
- **Resilience**: No central point of failure.

## 2. Data Structure

The Knowledge Graph is serialized into "Snapshots".

- **Format**: JSON/Binary (Compressed).
- **Signature**: Every snapshot is cryptographically signed by the node that generated it.
- **Content**: Nodes (Verses, Scholars, Opinions) and Edges.

## 3. Sync Mechanisms

### A. Sneakernet (Manual)

1. **Export**: User clicks "Export Snapshot" -> Downloads `citadel_snapshot_[timestamp].json.gz`.
2. **Transport**: File is moved via USB drive to an offline node.
3. **Import**: User clicks "Ingest Snapshot" -> System merges data.

### B. P2P (Future)

- **IPFS**: Snapshots are pinned to IPFS.
- **GossipSub**: Nodes gossip about new snapshot CIDs.

## 4. The Mizan (Conflict Resolution)

When merging snapshots, conflicts are resolved via "The Mizan":

- **Weighting**: Higher weight opinions (canonical) take precedence in visualization, but NO data is deleted.
- **Union**: The graph is an additive union of all ingested snapshots.

## 5. Security

- **Web of Trust**: Users can whitelist public keys (Scholars/Nodes) they trust.
- **Tamper Evidence**: Signatures ensure data hasn't been modified in transit.
