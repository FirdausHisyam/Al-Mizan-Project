# Multi-Sig Governance: The Hubris Check

## Overview

To protect the "Truth" from centralization risks (The "Sole Khalifah" problem), all Global Rulings require cryptographic consensus from a "Council of Ulema".

## The Protocol

1. **Propose**: A Council Member proposes a ruling via `POST /api/v1/authority/propose`.
    - Status: `Pending`.
2. **Sign**: Other members review and sign via `POST /api/v1/authority/sign`.
3. **Execute**: Once `signatures.len() >= required_signatures` (default 3), the ruling becomes `Active`.

## Security

- **No Single Point of Failure**: Even the Architect cannot unilaterally alter the graph.
- **Cryptographic Integrity**: All signatures are verified (mocked in MVP).
