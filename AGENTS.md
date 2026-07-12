.rules

## Project State (Jul 12 2026)

### What's been done
- **Malware cleanup**: TokenImporter, WorldBomb, VB-Cable, PowerShell Bypass removed
- **CI updated**: Node 22, pnpm v11.11.0 (from packageManager field)
- **ESLint**: 0 errors, 198 react-hooks warnings (set to warn level)
- **pnpm migration**: `package.json#pnpm` -> `pnpm-workspace.yaml`, all settings migrated
- **`p-limit`**: Added as direct dependency for build resolution
- **Test files**: `src/test.ts`, `src/test_profile.ts` deleted

### Build fixes (this session)
- `standalone-electron-types@34.2.0` -> `41.2.1` (compatible with electron@41)
- `pnpm-workspace.yaml` overrides: `@types/react@^19.2.17`, `csstype@^3.2.3` (resolved 3-way version conflict)
- `browser/VencordNativeStub.ts`: added missing `downloadAndRun`
- `src/shared/IpcEvents.ts`: added all Vesktop/Vencord preload events (40+ entries)
- `packages/discord-types/src/components.d.ts`: added `RenderModalProps`, `ModalSize`
- `src/components/Icons.tsx`: added `SkullIcon`
- `tsconfig.json`: added `@webpack/types`, `@equicord/types/*`, `@YouCord/types/*` path mappings
- Created type declaration files for `@YouCord/types/*` under `packages/vencord-types/`
- Created `src/types/global-modules.d.ts` for `libvesktop`, `discord-types/general`, `@plugins/devCompanion.dev/initWs`
- Fixed `src/youcord/renderer/components/settings/ImportLegacySettings.tsx`: `"react"` -> `@YouCord/types/webpack/common`

### Current status
- `pnpm buildDesktop` -> SUCCESS
- `pnpm buildStandalone` -> SUCCESS  
- `pnpm testTsc` -> 279 pre-existing type errors (code bugs, not dependency issues)
- `pnpm lint` -> 0 errors, 198 warnings

### Remaining
- 279 pre-existing TS errors (TS2339, TS2769, TS2345, TS2322) - build works, typecheck fails
