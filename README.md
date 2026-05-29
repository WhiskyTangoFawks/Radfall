# Radfall

Tools to build a Fallout 4 survival overhaul. This repository contains the source files, plugins, papyrus runtime scripts, and xedit patching scripts. These are tools to build Radfall against a load order, not a ready-to-install mod.

---

## What's in this repo

- Papyrus script sources (`.psc`)
- FO4Edit patcher scripts
- Plugins

---

## Requirements

- **Fallout 4** with the Creation Kit installed (if compiling papyrus scripts)
- **FO4Edit** (latest release)
- A working Fallout 4 mod load order to patch against

---

## Building

### 1. Compile the Papyrus scripts (or just download the release)

1. Load the plugin and source scripts into the **Creation Kit**.
2. Compile all scripts. Output the `.pex` files to your mod's `Scripts/` folder.

If you're compiling outside the CK, ensure your `Papyrus Compiler` flags file and import paths include the base Fallout 4 source scripts.
If you don't want to compile the scripts, download the compiled scripts from the github releases.

### 2. Run the FO4Edit patcher

1. Copy the patcher script and required dependencies into your edit scripts folder
2. Open **FO4Edit** with your full load order active.
3. Run it against your load order.
4. Save the generated patch plugin.

### 3. Generate custom patches (if needed)

If your load order includes mods that conflict with Radfall's changes, you will need to generate additional patches manually in FO4Edit. No pre-made patches are provided here — your load order is yours to manage.

---

## Troubleshooting

Support is not provided for self-built installations. If something is broken:

- Check that all scripts compiled without errors in the CK log if you're trying to compile them.
- Check that the patcher ran cleanly and the output plugin loaded correctly in FO4Edit.
- Check for conflicts in your load order using FO4Edit.

---

## License

[Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/)

You may share and adapt this source for non-commercial purposes, with attribution.
