# Vouch architecture

The diagram separates the request-time permission guard from advisory AWS reporting. The client and owner-phone interface are simulated, and the demo tool actions are mock implementations. The local Python hub is an optional path with TitaNet, Parakeet and Ed25519 signing.

![Vouch architecture](../gallery/07-architecture.png)

## Open the interactive version

Download [vouch-architecture.html](vouch-architecture.html) and open it in a browser. GitHub displays the HTML source; download the file to run it. The downloaded file is self-contained; no Archify installation is required. Following GitHub source links requires internet access.

Click a component to inspect its source references. Those links point to the source on `main`.

## Files and checks

- [PNG for the Devpost gallery](../gallery/07-architecture.png)
- [Scalable SVG](vouch-architecture.svg)
- [Editable Archify source](vouch-architecture.json)

Archify validation, delivery, artifact checks and browser checks passed. The exported PNG was visually inspected. Local check receipts are retained outside the public assets because they contain machine-specific paths.

The AWS export is an explicit file-based path, not a continuously running stream from PostgreSQL. Reports contain allowlisted metadata and cannot execute tools or change household permissions. Plain-language rule authoring and the reusable attestation library are outside this overview.

Generated with [Archify](https://github.com/tt-a1i/archify). Its MIT licence is included in [ARCHIFY-LICENSE.txt](ARCHIFY-LICENSE.txt).
