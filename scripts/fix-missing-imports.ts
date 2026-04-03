#!/usr/bin/env bun
/**
 * fix-missing-imports.ts - Add missing imports for angle-bracket components in .gjs files.
 *
 * Usage:
 *   bun scripts/fix-missing-imports.ts          # dry run
 *   bun scripts/fix-missing-imports.ts --apply  # apply
 */

import { Glob } from "bun";

const APPLY = process.argv.includes("--apply");
const ROOT = import.meta.dir + "/../assets/javascripts/discourse";

// Map of component PascalCase names to their import paths
// Relative paths are from the components/ directory
const IMPORT_MAP: Record<string, string> = {
  // Discourse core components
  DButton: 'import DButton from "discourse/components/d-button";',
  DEditor: 'import DEditor from "discourse/components/d-editor";',
  DModal: 'import DModal from "discourse/components/d-modal";',
  ConditionalLoadingSpinner: 'import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";',
  PluginOutlet: 'import PluginOutlet from "discourse/components/plugin-outlet";',
  NavItem: 'import NavItem from "discourse/components/nav-item";',
  ToolbarPopupMenuOptions: 'import ToolbarPopupMenuOptions from "discourse/components/toolbar-popup-menu-options";',
  UppyImageUploader: 'import UppyImageUploader from "discourse/components/uppy-image-uploader";',

  // Select-kit
  ComboBox: 'import ComboBox from "select-kit/components/combo-box";',
  MultiSelect: 'import MultiSelect from "select-kit/components/multi-select";',
  TagChooser: 'import TagChooser from "select-kit/components/tag-chooser";',
  CategoryChooser: 'import CategoryChooser from "select-kit/components/category-chooser";',

  // Plugin components (relative paths work from components/ dir)
  WizardSubscriptionSelector: 'import WizardSubscriptionSelector from "./wizard-subscription-selector";',
  WizardMapper: 'import WizardMapper from "./wizard-mapper";',
  WizardMessage: 'import WizardMessage from "./wizard-message";',
  WizardLinks: 'import WizardLinks from "./wizard-links";',
  WizardTextEditor: 'import WizardTextEditor from "./wizard-text-editor";',
  WizardRealtimeValidations: 'import WizardRealtimeValidations from "./wizard-realtime-validations";',
  WizardTableField: 'import WizardTableField from "./wizard-table-field";',
  WizardMapperConnector: 'import WizardMapperConnector from "./wizard-mapper-connector";',
  WizardMapperInput: 'import WizardMapperInput from "./wizard-mapper-input";',
  WizardMapperPair: 'import WizardMapperPair from "./wizard-mapper-pair";',
  WizardMapperSelector: 'import WizardMapperSelector from "./wizard-mapper-selector";',
  WizardMapperSelectorType: 'import WizardMapperSelectorType from "./wizard-mapper-selector-type";',
  WizardCustomAction: 'import WizardCustomAction from "./wizard-custom-action";',
  WizardCustomField: 'import WizardCustomField from "./wizard-custom-field";',
  WizardCustomStep: 'import WizardCustomStep from "./wizard-custom-step";',
  WizardValueList: 'import WizardValueList from "./wizard-value-list";',
  CustomWizardField: 'import CustomWizardField from "./custom-wizard-field";',
  CustomWizardStepForm: 'import CustomWizardStepForm from "./custom-wizard-step-form";',
  CustomWizardDateInput: 'import CustomWizardDateInput from "./custom-wizard-date-input";',
  CustomWizardTimeInput: 'import CustomWizardTimeInput from "./custom-wizard-time-input";',
  CustomWizardDateTimeInput: 'import CustomWizardDateTimeInput from "./custom-wizard-date-time-input";',
  CustomWizardCategorySelector: 'import CustomWizardCategorySelector from "./custom-wizard-category-selector";',
  CustomWizardGroupSelector: 'import CustomWizardGroupSelector from "./custom-wizard-group-selector";',
  CustomWizardTopicSelector: 'import CustomWizardTopicSelector from "./custom-wizard-topic-selector";',
  CustomWizardTagChooser: 'import CustomWizardTagChooser from "./custom-wizard-tag-chooser";',
  CustomWizardSimilarTopic: 'import CustomWizardSimilarTopic from "./custom-wizard-similar-topic";',
  CustomWizardEditor: 'import CustomWizardEditor from "./custom-wizard-editor";',
  CustomFieldInput: 'import CustomFieldInput from "./custom-field-input";',
  CustomUserSelector: 'import CustomUserSelector from "./custom-user-selector";',
};

const glob = new Glob("**/*.gjs");
let totalAdded = 0;
let totalFiles = 0;

for await (const relPath of glob.scan(ROOT)) {
  const filePath = `${ROOT}/${relPath}`;
  let content = await Bun.file(filePath).text();

  // Extract template
  const templateMatch = content.match(/<template>([\s\S]*?)<\/template>/);
  if (!templateMatch) continue;
  const template = templateMatch[1];

  // Find all <PascalCase> component invocations
  const componentUses = new Set<string>();
  const matches = template.matchAll(/<([A-Z][a-zA-Z]+)\b/g);
  for (const m of matches) {
    componentUses.add(m[1]);
  }

  const missing: string[] = [];
  for (const name of componentUses) {
    if (!IMPORT_MAP[name]) continue;
    // Check if already imported
    const importCheck = new RegExp(`import\\s+${name}\\b`);
    if (!importCheck.test(content)) {
      // Adjust relative path for templates/ directory
      let importStr = IMPORT_MAP[name];
      if (relPath.startsWith("templates/") && importStr.includes('from "./')) {
        importStr = importStr.replace('from "./', 'from "../components/');
      }
      if (relPath.startsWith("connectors/") && importStr.includes('from "./')) {
        importStr = importStr.replace('from "./', 'from "../../components/');
      }
      missing.push(importStr);
    }
  }

  if (missing.length > 0) {
    totalFiles++;
    totalAdded += missing.length;
    console.log(`${relPath}: +${missing.length} imports`);

    if (APPLY) {
      const lines = content.split("\n");
      let lastImportIdx = -1;
      for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith("import ")) lastImportIdx = i;
      }

      const unique = [...new Set(missing)];
      if (lastImportIdx >= 0) {
        lines.splice(lastImportIdx + 1, 0, ...unique);
      } else {
        lines.unshift(...unique, "");
      }
      await Bun.write(filePath, lines.join("\n"));
    }
  }
}

console.log(`\n${totalAdded} imports across ${totalFiles} files.`);
if (!APPLY) console.log("Run with --apply to apply.");
