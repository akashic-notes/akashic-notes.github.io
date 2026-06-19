import { defineCollection } from "astro:content";
import { akashicNotesLoader } from "@akashic-notes/astro-collection";

const notes = defineCollection({
  loader: akashicNotesLoader({
    repository: "akhilpai/akashic-notes",
    path: "/akashic-notes/akashic-notes.github.io",
  }),
});

export const collections = { notes };
