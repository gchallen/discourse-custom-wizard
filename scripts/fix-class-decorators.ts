#!/usr/bin/env bun
/**
 * fix-class-decorators.ts - Convert classNameBindings, classNames, and tagName
 * from class fields to @ember-decorators/component decorators in .gjs files.
 *
 * BEFORE:
 *   export default class extends Component {
 *     classNameBindings = [":wizard-step", "step.id"];
 *     classNames = ["my-class"];
 *     tagName = "tr";
 *
 * AFTER:
 *   import { classNameBindings, classNames, tagName } from "@ember-decorators/component";
 *
 *   @classNameBindings(":wizard-step", "step.id")
 *   @classNames("my-class")
 *   @tagName("tr")
 *   export default class extends Component {
 *
 * Usage:
 *   bun scripts/fix-class-decorators.ts          # dry run
 *   bun scripts/fix-class-decorators.ts --apply  # apply
 */

import { Glob } from "bun";

const APPLY = process.argv.includes("--apply");
const ROOT = import.meta.dir + "/../assets/javascripts/discourse";

const glob = new Glob("**/*.gjs");
let totalFixes = 0;
let totalFiles = 0;

for await (const relPath of glob.scan(ROOT)) {
  const filePath = `${ROOT}/${relPath}`;
  let content = await Bun.file(filePath).text();

  const decorators: string[] = [];
  const imports: string[] = [];
  let fixes = 0;

  // Match classNameBindings = [...];
  const cnbMatch = content.match(
    /\s+classNameBindings\s*=\s*\[([\s\S]*?)\];/
  );
  if (cnbMatch) {
    const items = cnbMatch[1]
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean);
    decorators.push(`@classNameBindings(${items.join(", ")})`);
    imports.push("classNameBindings");
    content = content.replace(cnbMatch[0], "");
    fixes++;
  }

  // Match classNames = [...];
  const cnMatch = content.match(/\s+classNames\s*=\s*\[([\s\S]*?)\];/);
  if (cnMatch) {
    const items = cnMatch[1]
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean);
    decorators.push(`@classNames(${items.join(", ")})`);
    imports.push("classNames");
    content = content.replace(cnMatch[0], "");
    fixes++;
  }

  // Match tagName = "...";
  const tnMatch = content.match(/\s+tagName\s*=\s*("[^"]*");/);
  if (tnMatch) {
    decorators.push(`@tagName(${tnMatch[1]})`);
    imports.push("tagName");
    content = content.replace(tnMatch[0], "");
    fixes++;
  }

  if (fixes > 0) {
    totalFiles++;
    totalFixes += fixes;

    // Add decorators before class declaration
    const classMatch = content.match(
      /export default class\b/
    );
    if (classMatch && classMatch.index !== undefined) {
      const decoratorStr = decorators.join("\n") + "\n";
      content =
        content.substring(0, classMatch.index) +
        decoratorStr +
        content.substring(classMatch.index);
    }

    // Add import for @ember-decorators/component
    const importStr = `import { ${imports.join(", ")} } from "@ember-decorators/component";`;
    // Check if already imported
    if (!content.includes("@ember-decorators/component")) {
      const lastImportIdx = content.lastIndexOf("\nimport ");
      if (lastImportIdx >= 0) {
        const lineEnd = content.indexOf("\n", lastImportIdx + 1);
        content =
          content.substring(0, lineEnd + 1) +
          importStr +
          "\n" +
          content.substring(lineEnd + 1);
      }
    }

    console.log(
      `${relPath}: ${fixes} fields -> decorators (${imports.join(", ")})`
    );

    if (APPLY) {
      await Bun.write(filePath, content);
    }
  }
}

console.log(`\n${totalFixes} conversions across ${totalFiles} files.`);
if (!APPLY) console.log("Run with --apply to apply.");
