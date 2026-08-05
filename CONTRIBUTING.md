# Site module specification

This repository publishes a static Astro site. It has two distinct viewers:

- the existing build-time `notes` collection, which remains the public default
  viewer for `akhilpai/akashic-notes`; and
- a client-side workspace for repositories configured by an individual user.

The client workspace is intentionally not an Astro Live Content Collection.
It runs entirely in the browser and must not require an Astro server runtime.
It uses `@akashic-notes/storage` with isomorphic-git for repository access.

## Settled constraints

- The deployment remains static.
- Many users may configure their own repositories. Their configuration, cloned
  data, and credentials are isolated in that browser's storage.
- Users supply PATs and they persist locally in the browser. They are never
  included in static output, URLs, exports, or user-visible diagnostics.
- The initial CORS proxy is replaceable. It handles PAT-bearing requests and
  must be security-reviewed before release.
- The initial product supports GitHub repositories only. GitHub Enterprise and
  other Git hosts are outside this specification.
- Adding a repository validates the supported Akashic repository contract up
  front and rejects an invalid repository with an actionable error. View
  filters (including Trilium-style hoisting) are out of scope.
- For this release, the Akashic layout must be at the repository root.
  Selecting an Akashic subdirectory is deferred until `@akashic-notes/storage`
  supports it.
- Repository setup accepts an optional branch. Without one, it resolves the
  GitHub default branch at setup and persists the resulting selected branch.
- Edits commit and push directly to the selected branch; PR publication is out
  of scope.
- Editing supports record creation, reading, update, deletion, rename/move,
  reparenting, and cloning to a new record name. Missing storage-library
  operations remain explicit implementation placeholders rather than being
  approximated in the site.
- Clone, move, and reparent operations apply to the selected name and its
  visible subtree.
- Deletion removes only the selected name; the underlying record and any other
  names remain.
- Direct commits use the authenticated GitHub account's identity. The mechanism
  used to obtain that identity is intentionally not specified here.
- Synchronization is requested when the app opens. It is not guaranteed while
  the app is closed. While the app is open, configured repositories synchronize
  every three hours. Transient failures retry automatically.
- Storage operations leave no uncommitted working-tree or staging changes.
  Synchronization conflicts are reported as errors in this release.
- Configured repository content is trusted for the initial release.

## Module boundaries

`src/` contains the static shell and client application specifications in
[`src/CONTRIBUTING.md`](src/CONTRIBUTING.md). `src/lib/` owns browser-only
configuration, credential, workspace, synchronization, and rendering models;
its contract is in [`src/lib/CONTRIBUTING.md`](src/lib/CONTRIBUTING.md).

The upstream `@akashic-notes/storage` package owns the Git and Akashic-record
operations described in the storage-extension section of that module contract.
Changes to that package must be specified and tested there before this site
depends on them.
