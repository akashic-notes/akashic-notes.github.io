import type { CollectionEntry } from "astro:content";

export type NoteEntry = CollectionEntry<"notes">;

export interface NoteTreeNode {
  note: NoteEntry;
  children: NoteTreeNode[];
}

export function sortNotes(notes: NoteEntry[]) {
  return [...notes].sort((left, right) => sortPath(left.data.path).localeCompare(sortPath(right.data.path)));
}

export function noteHref(note: NoteEntry) {
  return note.data.path === "/index" ? "/" : note.data.path;
}

export function parentRecordPath(path: string) {
  if (path === "/index") {
    return null;
  }
  const segments = path.split("/").filter(Boolean);
  if (segments.length <= 1) {
    return "/index";
  }
  return `/${segments.slice(0, -1).join("/")}`;
}

export function childNotes(notes: NoteEntry[], note: NoteEntry) {
  return sortNotes(notes).filter((candidate) => parentRecordPath(candidate.data.path) === note.data.path);
}

export function siblingNavigation(notes: NoteEntry[], note: NoteEntry) {
  const sorted = sortNotes(notes);
  const index = sorted.findIndex((candidate) => candidate.id === note.id);
  return {
    index,
    total: sorted.length,
    previous: index > 0 ? sorted[index - 1] : null,
    next: index >= 0 && index < sorted.length - 1 ? sorted[index + 1] : null,
  };
}

export function noteTree(notes: NoteEntry[]) {
  const sorted = sortNotes(notes);
  const byPath = new Map(sorted.map((note) => [note.data.path, note]));
  const childrenByParent = new Map<string, NoteEntry[]>();
  const roots: NoteEntry[] = [];

  for (const note of sorted) {
    const parentPath = parentRecordPath(note.data.path);
    if (!parentPath || !byPath.has(parentPath)) {
      roots.push(note);
      continue;
    }
    childrenByParent.set(parentPath, [...(childrenByParent.get(parentPath) ?? []), note]);
  }

  const build = (entry: NoteEntry): NoteTreeNode => ({
    note: entry,
    children: (childrenByParent.get(entry.data.path) ?? []).map(build),
  });

  return roots.map(build);
}

function sortPath(path: string) {
  return path === "/index" ? "/" : path;
}
