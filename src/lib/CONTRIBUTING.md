# `src/lib` module specification

`src/lib` provides the browser-only workspace behind the configured-repository
experience. It has no server-runtime responsibility.

## Responsibilities

- Keep each user's repository settings, credentials, local repository data,
  and synchronization state private to that browser.
- Add a GitHub repository only after validating a supported Akashic repository
  at its root. Reject invalid repositories clearly and without a partial
  workspace.
- Use the branch chosen at setup, or resolve and retain GitHub's default branch
  at setup when none is chosen.
- Read and project Akashic records for the client viewer.
- Provide the client viewer with a repository picker and repository-scoped
  identities for navigation.
- Support record CRUD, rename/move, reparenting, and cloning to a new record
  name; clone, move, and reparent apply to the selected name and its visible
  subtree.
- Deleting removes only the selected name; it preserves the underlying record
  and any other names.
- Synchronize configured repositories on app open and every three hours while
  the app is open. Retry transient failures automatically, preserve readable
  local data, and report safe, actionable status when synchronization fails.
- Commit mutations as the authenticated GitHub account and directly publish
  them to the selected branch. A failed publish retains the local result.
- Leave no uncommitted working-tree or staging changes. Report synchronization
  conflicts as errors in this release.

## Boundaries

- Repository settings must not contain a PAT. PATs persist only in the
  browser's credential store and are not exposed in URLs, exports, diagnostics,
  or static output.
- The initial transport is the configurable project CORS proxy. It handles
  PAT-bearing requests and must be security-reviewed before release.
- View filters, repository subdirectories, non-GitHub hosts, PR publication,
  and synchronization after the app is closed are out of scope.

## Storage-library dependency

This module uses `@akashic-notes/storage` for repository and record changes.
Where a required operation is unavailable, it remains an explicit placeholder
until the library supports it.

## Accepted risk and TODO

Configured repository content is trusted in this release and shares an origin
with persistent credentials. Before untrusted repositories are supported,
define and implement a separate rendering-isolation policy.

## Open product decisions

- Whether a credential can be reused across configured repositories.
- How a user composes commit messages.
