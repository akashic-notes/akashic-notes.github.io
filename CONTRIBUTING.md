# Handoff: Astro Akashic Notes Collection

This repo is being converted from a static `zero-md` page to a minimal Astro site that consumes an Akashic Notes content collection from `../astro-collection`.

## Current State

The sibling package `../astro-collection` has been scaffolded as `@akashic-notes/astro-collection`.

It currently exports:

- `akashicNotesLoader(options)`: an Astro content loader.
- `akashicNoteSchema`: the default note schema for loaded entries.
- `AkashicNotesLoaderOptions`: loader options.
- `AkashicNoteData`: normalized note data.

The site now has:

- `package.json`: Astro scripts and dependencies.
- `astro.config.mjs`: minimal Astro config for `https://akashic-notes.github.io`.
- `tsconfig.json`: Astro strict config.
- `src/content.config.ts`: defines a `notes` collection using `akashicNotesLoader`.
- `src/pages/index.astro`: renders the `/index` note, falling back to the first loaded note.
- `src/pages/[...slug].astro`: renders non-index notes as static paths.

The old `index.html` zero-md entrypoint has been deleted.

## Loader Contract

The loader currently expects source notes to be ordinary files in a GitHub repository directory.

Configured in `src/content.config.ts`:

```ts
const notes = defineCollection({
  loader: akashicNotesLoader({
    repository: "akhilpai/akashic-notes",
    path: "/akashic-notes/akashic-notes.github.io",
  }),
});
```

Supported file types:

- `.md`
- `.mdx`
- `.json`

Markdown notes:

- Optional frontmatter is parsed with `gray-matter`.
- `title` comes from frontmatter `title`, then the first `# heading`, then the file name.
- `body` is the Markdown body after frontmatter.
- `metadata` is the remaining frontmatter object.

JSON notes:

- `title` comes from `title`, then file name.
- `body` comes from `body`, defaulting to an empty string.
- `metadata` comes from `metadata` if present, otherwise all JSON fields except `title` and `body`.

Normalized entry data:

```ts
{
  title: string;
  path: string;
  slug: string;
  sourcePath: string;
  format: "markdown" | "json";
  body: string;
  metadata: Record<string, JsonValue>;
}
```

This is intentionally simpler than the current internal Akashic `/.records/<id>/.data` and symlink record-path storage. The data source can be updated later to emit this file-oriented shape.

## GitHub Access

The loader uses `@octokit/rest` and accepts:

```ts
{
  repository: "owner/name";
  path: "/path/inside/repo";
  branch?: string;
  token?: string;
  extensions?: readonly string[];
}
```

If `token` is not provided, it reads `process.env.GITHUB_TOKEN`.

This matches the intended private-repo path for CI, but it does not yet integrate directly with the browser-extension GitHub app login flow. The relevant prior art is in `../webextension`, where a user access token is obtained through the GitHub login worker and then passed into git operations.

## Verification

Completed:

```sh
cd ../astro-collection
pnpm install
pnpm run typecheck
```

`pnpm run typecheck` passed for `../astro-collection`.

Attempted:

```sh
cd ../akashic-notes.github.io
pnpm install
pnpm run build
```

Install completed, but build verification was interrupted before completion. Before the interruption, sandboxed builds failed while Vite tried to write cache files under `node_modules/.vite`. Running the build with approval/escalation should be retried.

## Known Issues

- `../astro-collection/node_modules` and this repo's `node_modules` were created during the handoff work and are untracked.
- `pnpm-lock.yaml` was generated in both repos.
- Astro build has not been fully verified for this repo after the Vite cache issue.
- The loader imports `astro/loaders` and should be rechecked against the final Astro version used by the site.
- `@akashic-notes/web` is listed as a dependency of `../astro-collection`, but the current loader does not import it because that package does not currently expose usable published TypeScript declarations through package exports.
- The current source contract is file-based. It does not yet read the existing Akashic record graph directly.

## Suggested Next Steps

1. Re-run the site build with normal filesystem/network permissions:

   ```sh
   cd ../akashic-notes.github.io
   pnpm run build
   ```

2. If the build reaches the loader and GitHub returns a not-found error, confirm that `akhilpai/akashic-notes` contains note files under `akashic-notes/akashic-notes.github.io` on the default branch.

3. Decide whether the canonical source format should remain simple Markdown/JSON files or whether `../astro-collection` should translate the existing `/.records` storage model from `../web`.

4. If private repository access is required in CI, provide `GITHUB_TOKEN` in the build environment or pass `token` explicitly in `src/content.config.ts`.

5. If the package should be consumed outside this local workspace, add a real build step for `../astro-collection` that emits `dist` declarations and JavaScript instead of exporting `src/index.ts` directly.
