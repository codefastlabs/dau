import assert from "node:assert/strict";
import { test } from "vitest";
import { en } from "#i18n/en";
import { vi } from "#i18n/vi";

/** Every string of a dictionary with its key path; the type check cannot see empty strings. */
function strings(value: unknown, path = ""): [string, string][] {
  if (typeof value === "string") return [[path, value]];
  if (Array.isArray(value))
    return value.flatMap((item, index) => strings(item, `${path}[${index}]`));
  if (typeof value === "object" && value !== null) {
    return Object.entries(value).flatMap(([key, inner]) =>
      strings(inner, path ? `${path}.${key}` : key),
    );
  }
  return [];
}

for (const [name, messages] of [
  ["vi", vi],
  ["en", en],
] as const) {
  test(`${name}: no string is empty`, () => {
    const empty = strings(messages).filter(([, text]) => text.trim() === "");
    assert.deepEqual(empty, []);
  });
}

test("en has the same keys as vi, in the same order", () => {
  assert.deepEqual(
    strings(en).map(([path]) => path),
    strings(vi).map(([path]) => path),
  );
});
