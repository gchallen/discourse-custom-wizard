#!/usr/bin/env bun
/**
 * fix-action-helpers.ts - Replace deprecated (action ...) template helper
 * with direct method references in .gjs files.
 *
 * Patterns:
 *   (action "methodName")           -> this.methodName
 *   (action "methodName" param)     -> (fn this.methodName param)
 *   (action (mut this.prop))        -> (fn (mut this.prop))
 *   action=(action "methodName")    -> @action={{this.methodName}}  (when used as component arg)
 *
 * Usage:
 *   bun scripts/fix-action-helpers.ts          # dry run
 *   bun scripts/fix-action-helpers.ts --apply  # apply
 */

import { Glob } from "bun";

const APPLY = process.argv.includes("--apply");
const ROOT = import.meta.dir + "/../assets/javascripts/discourse";

const glob = new Glob("**/*.gjs");
let totalFixed = 0;
let totalFiles = 0;

for await (const relPath of glob.scan(ROOT)) {
  const filePath = `${ROOT}/${relPath}`;
  let content = await Bun.file(filePath).text();
  const original = content;

  // Find the <template> section
  const templateStart = content.indexOf("<template>");
  const templateEnd = content.lastIndexOf("</template>");
  if (templateStart === -1 || templateEnd === -1) continue;

  let before = content.substring(0, templateStart + "<template>".length);
  let template = content.substring(
    templateStart + "<template>".length,
    templateEnd
  );
  let after = content.substring(templateEnd);

  let fixes = 0;
  let needsFn = false;
  let needsMut = false;

  // Pattern 1: (action "methodName") with no extra args -> this.methodName
  // But only when NOT inside (action (mut ...))
  template = template.replace(
    /\(action\s+"([^"]+)"\s*\)/g,
    (match, method) => {
      fixes++;
      return `this.${method}`;
    }
  );

  // Pattern 2: (action "methodName" param) -> (fn this.methodName param)
  template = template.replace(
    /\(action\s+"([^"]+)"\s+([^)]+)\)/g,
    (match, method, params) => {
      fixes++;
      needsFn = true;
      return `(fn this.${method} ${params.trim()})`;
    }
  );

  // Pattern 3: (action (mut this.prop)) -> (fn (mut this.prop))
  template = template.replace(
    /\(action\s+\(mut\s+([^)]+)\)\)/g,
    (match, prop) => {
      fixes++;
      needsFn = true;
      needsMut = true;
      return `(fn (mut ${prop}))`;
    }
  );

  // Pattern 4: Remaining (action ...) with complex expressions
  // (action b.action b) -> (fn b.action b)
  template = template.replace(
    /\(action\s+([a-zA-Z][a-zA-Z0-9_.]+)\s+([^)]+)\)/g,
    (match, expr, params) => {
      if (expr.startsWith('"')) return match; // Already handled
      fixes++;
      needsFn = true;
      return `(fn ${expr} ${params.trim()})`;
    }
  );

  if (fixes > 0) {
    totalFiles++;
    totalFixed += fixes;

    content = before + template + after;

    // Add missing imports
    if (needsFn && !content.includes('import { fn }')) {
      if (content.includes('from "@ember/helper"')) {
        // Add fn to existing @ember/helper import
        content = content.replace(
          /import\s*\{([^}]+)\}\s*from\s*["']@ember\/helper["']/,
          (match, imports) => {
            if (imports.includes("fn")) return match;
            return `import { ${imports.trim()}, fn } from "@ember/helper"`;
          }
        );
      } else {
        // Add new import
        const firstImport = content.indexOf("import ");
        if (firstImport >= 0) {
          const lineEnd = content.indexOf("\n", firstImport);
          content =
            content.substring(0, lineEnd + 1) +
            'import { fn } from "@ember/helper";\n' +
            content.substring(lineEnd + 1);
        }
      }
    }

    if (needsMut && !content.includes("import { mut }") && !content.includes("import mut")) {
      const firstImport = content.indexOf("import ");
      if (firstImport >= 0) {
        const lineEnd = content.indexOf("\n", firstImport);
        content =
          content.substring(0, lineEnd + 1) +
          'import { mut } from "discourse/helpers/mut";\n' +
          content.substring(lineEnd + 1);
      }
    }

    console.log(`${relPath}: ${fixes} fixes${needsFn ? " (+fn)" : ""}${needsMut ? " (+mut)" : ""}`);

    if (APPLY) {
      await Bun.write(filePath, content);
    }
  }
}

console.log(`\n${totalFixed} fixes across ${totalFiles} files.`);
if (!APPLY) console.log("Run with --apply to apply.");
