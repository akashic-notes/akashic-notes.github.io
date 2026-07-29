set dotenv-load := true

mod auth

# Populate Astro content collections using @akashic-notes/astro-collection-loader.
populate: auth::github-staging
    ASTRO_TELEMETRY_DISABLED=1 pnpm exec astro sync

# Populate content, then run the local Astro dev server.
dev: populate
    pnpm run dev

pnpm +pnpm-args="":
	pnpm {{ pnpm-args }}
