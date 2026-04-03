#!/usr/bin/env bun
/**
 * fix-curly-to-angle.ts - Convert curly-brace component invocations to
 * angle-bracket syntax in .gjs files for strict mode compatibility.
 *
 * {{componentName arg=val}} -> <ComponentName @arg={{val}} />
 *
 * Usage:
 *   bun scripts/fix-curly-to-angle.ts          # dry run
 *   bun scripts/fix-curly-to-angle.ts --apply  # apply
 */

import { Glob } from "bun";

const APPLY = process.argv.includes("--apply");
const ROOT = import.meta.dir + "/../assets/javascripts/discourse";

// Components that should be converted from curly to angle bracket.
// Maps the camelCase import name to the PascalCase tag name.
const COMPONENT_MAP: Record<string, string> = {
  dButton: "DButton",
  comboBox: "ComboBox",
  multiSelect: "MultiSelect",
  tagChooser: "TagChooser",
  categoryChooser: "CategoryChooser",
  conditionalLoadingSpinner: "ConditionalLoadingSpinner",
  toolbarPopupMenuOptions: "ToolbarPopupMenuOptions",
  uppyImageUploader: "UppyImageUploader",
  dEditor: "DEditor",
  navItem: "NavItem",
  wizardSubscriptionSelector: "WizardSubscriptionSelector",
  wizardMapper: "WizardMapper",
  wizardMessage: "WizardMessage",
  wizardLinks: "WizardLinks",
  wizardTextEditor: "WizardTextEditor",
  wizardRealtimeValidations: "WizardRealtimeValidations",
  wizardTableField: "WizardTableField",
  wizardMapperConnector: "WizardMapperConnector",
  wizardMapperInput: "WizardMapperInput",
  wizardMapperPair: "WizardMapperPair",
  wizardMapperSelector: "WizardMapperSelector",
  wizardMapperSelectorType: "WizardMapperSelectorType",
  wizardCustomAction: "WizardCustomAction",
  wizardCustomField: "WizardCustomField",
  wizardCustomStep: "WizardCustomStep",
  customWizardField: "CustomWizardField",
  customWizardStepForm: "CustomWizardStepForm",
  customWizardDateInput: "CustomWizardDateInput",
  customWizardTimeInput: "CustomWizardTimeInput",
  customWizardDateTimeInput: "CustomWizardDateTimeInput",
  customWizardCategorySelector: "CustomWizardCategorySelector",
  customWizardGroupSelector: "CustomWizardGroupSelector",
  customWizardTopicSelector: "CustomWizardTopicSelector",
  customWizardTagChooser: "CustomWizardTagChooser",
  customWizardTextField: "CustomWizardTextField",
  customWizardTextareaEditor: "CustomWizardTextareaEditor",
  customWizardSimilarTopic: "CustomWizardSimilarTopic",
  customWizardEditor: "CustomWizardEditor",
  customFieldInput: "CustomFieldInput",
  customUserSelector: "CustomUserSelector",
  wizardValueList: "WizardValueList",
};

function convertCurlyToAngle(template: string): { result: string; fixes: number } {
  let fixes = 0;

  for (const [camelName, pascalName] of Object.entries(COMPONENT_MAP)) {
    // Match {{camelName arg1=val1 arg2=val2 ...}}
    // This regex handles self-closing curly invocations
    const selfClosingRegex = new RegExp(
      `\\{\\{${camelName}\\s+([^}]+?)\\}\\}`,
      "g"
    );

    template = template.replace(selfClosingRegex, (match, argsStr) => {
      // Don't convert if it's inside a subexpression like (componentName ...)
      // or if it's a block component {{#componentName}}
      if (match.startsWith("{{#")) return match;

      // Convert args: arg=val -> @arg={{val}}
      const convertedArgs = convertArgs(argsStr.trim());
      fixes++;
      return `<${pascalName} ${convertedArgs} />`;
    });

    // Match block form: {{#camelName ...}}...{{/camelName}}
    const blockRegex = new RegExp(
      `\\{\\{#${camelName}\\s+([^}]*?)\\}\\}([\\s\\S]*?)\\{\\{/${camelName}\\}\\}`,
      "g"
    );

    template = template.replace(blockRegex, (match, argsStr, content) => {
      const convertedArgs = convertArgs(argsStr.trim());
      fixes++;
      return `<${pascalName} ${convertedArgs}>${content}</${pascalName}>`;
    });
  }

  return { result: template, fixes };
}

function convertArgs(argsStr: string): string {
  // Parse arguments like: arg1=val1 arg2="string" arg3=(helper x)
  // Convert to: @arg1={{val1}} @arg2="string" @arg3={{(helper x)}}

  // Split on spaces that are not inside parens or quotes
  const args: string[] = [];
  let current = "";
  let parenDepth = 0;
  let inQuote = false;
  let quoteChar = "";

  for (let i = 0; i < argsStr.length; i++) {
    const ch = argsStr[i];

    if (!inQuote && (ch === '"' || ch === "'")) {
      inQuote = true;
      quoteChar = ch;
      current += ch;
    } else if (inQuote && ch === quoteChar) {
      inQuote = false;
      current += ch;
    } else if (!inQuote && ch === "(") {
      parenDepth++;
      current += ch;
    } else if (!inQuote && ch === ")") {
      parenDepth--;
      current += ch;
    } else if (!inQuote && parenDepth === 0 && ch === " ") {
      if (current.trim()) args.push(current.trim());
      current = "";
    } else {
      current += ch;
    }
  }
  if (current.trim()) args.push(current.trim());

  return args
    .map((arg) => {
      const eqIdx = arg.indexOf("=");
      if (eqIdx === -1) {
        // Positional arg or flag - keep as-is with @
        return arg;
      }

      const key = arg.substring(0, eqIdx);
      const val = arg.substring(eqIdx + 1);

      // Skip class= (HTML attribute, not component arg)
      if (key === "class") {
        return `class=${val}`;
      }

      // If value is a quoted string, use @key="string"
      if (
        (val.startsWith('"') && val.endsWith('"')) ||
        (val.startsWith("'") && val.endsWith("'"))
      ) {
        return `@${key}=${val}`;
      }

      // If value is a subexpression (hash ...) or (fn ...), wrap in {{}}
      if (val.startsWith("(") && val.endsWith(")")) {
        return `@${key}={{${val}}}`;
      }

      // If value is true/false, use @key={{true}}
      if (val === "true" || val === "false") {
        return `@${key}={{${val}}}`;
      }

      // Otherwise wrap in {{}}
      return `@${key}={{${val}}}`;
    })
    .join(" ");
}

// Process files
const glob = new Glob("**/*.gjs");
let totalFixes = 0;
let totalFiles = 0;

for await (const relPath of glob.scan(ROOT)) {
  const filePath = `${ROOT}/${relPath}`;
  const content = await Bun.file(filePath).text();

  // Extract template section
  const templateStart = content.indexOf("<template>");
  const templateEnd = content.lastIndexOf("</template>");
  if (templateStart === -1 || templateEnd === -1) continue;

  const before = content.substring(0, templateStart + "<template>".length);
  const template = content.substring(
    templateStart + "<template>".length,
    templateEnd
  );
  const after = content.substring(templateEnd);

  const { result, fixes } = convertCurlyToAngle(template);

  if (fixes > 0) {
    totalFiles++;
    totalFixes += fixes;
    console.log(`${relPath}: ${fixes} conversions`);

    if (APPLY) {
      await Bun.write(filePath, before + result + after);
    }
  }
}

console.log(`\n${totalFixes} conversions across ${totalFiles} files.`);
if (!APPLY) console.log("Run with --apply to apply.");
