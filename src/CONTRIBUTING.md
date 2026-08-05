# `src` module specification

`src` delivers a static public shell plus a progressively enhanced browser
workspace. Server-side Astro content APIs remain responsible only for the
existing build-time `notes` viewer. User-configured repositories are never
loaded into Astro's build content store.

## Public shell

- The existing static routes and default repository viewing behavior remain
  available without JavaScript.
- Loading the client workspace must not expose a user's configured repository
  names, contents, proxy endpoint, or PAT in the static build output.
- The client workspace provides a repository picker. Navigation must avoid
  collisions between equal record paths from different repositories.

## Browser workspace

- The workspace adds, opens, edits, synchronizes, and removes configured
  repositories using browser-only modules in `src/lib`.
- Editing includes record CRUD, rename/move, reparenting, and cloning a record
  to a new record name. Clone, move, and reparent apply to the selected name
  and its visible subtree.
- Repository onboarding validates the supported Akashic layout before a
  workspace is accepted. The layout must be at the repository root in this
  release. An invalid repository is rejected up front rather than partially
  displayed. Selecting a repository subdirectory is deferred pending storage
  library support.
- Setup uses a user-selected branch when provided; otherwise it resolves and
  retains the GitHub default branch.
- Opening the application requests synchronization; while it remains open,
  configured repositories synchronize every three hours. Transient failures
  retry automatically. The UI shows status and errors.
- The UI tells users that the configured proxy handles PAT-bearing requests and
  that they can remove a repository and its locally stored data.
- Before adding a repository, the UI must state that its content is treated as
  trusted in this release and can execute on the same origin as the persisted
  credential.

## Rendering

- The build-time viewer preserves its current rendering behavior.
- The client viewer renders the Akashic record model supplied by the browser
  workspace, not an Astro live collection.
- **TODO(security):** Configured repository HTML is treated as trusted for the
  initial release even though a persistent PAT is available on the same origin.
  Before supporting untrusted repositories, specify and implement either a
  sanitizer with a defined policy or an isolated sandboxed rendering origin.
