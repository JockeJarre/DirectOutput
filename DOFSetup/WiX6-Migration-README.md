# DirectOutput WiX 6 Migration Guide

This document outlines the migration from WiX 3 to WiX 6 for the DirectOutput installer.

## Migration Status

### Completed ?
- ? WiX v4+ schema migration (all .wxs files)
- ? Centralized variables in `DirectOutputVariables.wxi`
- ? WiX 6 SDK-style project file (`DOFSetup_WiX6_Migration.wixproj`)
- ? Preserved original UpgradeCode values for x86/x64
- ? Updated custom action references for WiX 6 DTF
- ? Automated COM object harvesting with WiX 6 CLI

### In Progress ??
- ?? COM object registration harvesting (automated via build targets)
- ?? Custom action DLL compilation for WiX 6
- ?? Testing and validation

### Pending ?
- ? Legacy project deprecation
- ? CI/CD pipeline updates
- ? Documentation updates

## Key Changes

### 1. Schema Migration
- Updated all `.wxs` files to WiX v4+ schema
- Changed `<Product>` to `<Package>` element
- Updated namespace to `http://wixtoolset.org/schemas/v4/wxs`

### 2. Centralized Variables
Created `DirectOutputVariables.wxi` containing:
- Platform-specific UpgradeCode values (preserved from WiX 3)
- Product names and bitness identifiers
- COM object GUID definition

### 3. Project Structure
```
DOFSetup/
??? Product.wxs                    # Main installer definition (WiX v4+)
??? DirectOutputVariables.wxi     # Centralized variables
??? DOFSetup_WiX6_Migration.wixproj # New WiX 6 SDK project
??? Build-WiX6.ps1               # Build automation script
??? Generated/                    # Auto-generated COM registration
?   ??? RegisterDirectOutputComObjectDll.wxs
?   ??? RegisterDirectOutputComObjectTlb.wxs
??? res/                          # UI resources (bitmaps, license)
```

### 4. Custom Actions
- Updated to use WiX 6 DTF (`WixToolset.Dtf.WindowsInstaller`)
- Separate WiX 6 compatible projects:
  - `DOFSetupB2SFixup_WiX6.csproj`
  - `DOFSetupPBXFixup_WiX6.csproj`

## Building with WiX 6

### Prerequisites
1. Install .NET 4.8 or later
2. Install WiX 6 toolset: https://wixtoolset.org/releases/

### Build Commands

#### Using PowerShell Script (Recommended)
```powershell
# Build x86 version
.\Build-WiX6.ps1 -Platform x86

# Build x64 version  
.\Build-WiX6.ps1 -Platform x64

# Build both platforms
.\Build-WiX6.ps1 -BuildBoth

# Regenerate COM registration and build
.\Build-WiX6.ps1 -UpdateHarvest -BuildBoth

# Clean and rebuild
.\Build-WiX6.ps1 -Clean -BuildBoth
```

#### Using MSBuild Directly
```cmd
dotnet build DOFSetup_WiX6_Migration.wixproj /p:Platform=x86
dotnet build DOFSetup_WiX6_Migration.wixproj /p:Platform=x64
```

### COM Object Harvesting
The build automatically harvests COM registration from:
- `DirectOutputComObject.dll` ? `Generated\RegisterDirectOutputComObjectDll.wxs`
- `DirectOutputComObject.tlb` ? `Generated\RegisterDirectOutputComObjectTlb.wxs`

To force regeneration: `/p:UpdateHarvest=true`

## Upgrade Code Preservation

**CRITICAL**: The migration preserves the original UpgradeCode values:
- **x86**: `94E0D0EE-C078-42C6-AD9F-4030B329A040`
- **x64**: `A7EAB3EB-6524-4173-B5D8-25FC867BD29E`

This ensures proper upgrade behavior from existing WiX 3 installations.

## Testing

### Validation Checklist
- [ ] x86 installer builds successfully
- [ ] x64 installer builds successfully  
- [ ] COM object registration works
- [ ] Custom actions execute correctly
- [ ] Upgrade from WiX 3 installer works
- [ ] UI displays correctly
- [ ] File installation to correct locations

### Test Scenarios
1. **Clean Install**: Fresh installation on clean VM
2. **Upgrade Install**: Install over existing WiX 3 version
3. **Repair**: Repair existing installation
4. **Uninstall**: Complete removal verification
5. **Coexistence**: x86 and x64 side-by-side installation

## Migration Benefits

### WiX 6 Advantages
- Modern .NET SDK-style project format
- Improved build performance
- Better integration with .NET toolchain
- Enhanced debugging capabilities
- Future-proofed for ongoing WiX development

### Maintained Compatibility
- Same installation behavior as WiX 3 version
- Identical file layout and registry entries
- Preserved upgrade paths and product codes
- No changes to end-user experience

## Troubleshooting

### Common Issues

#### Build Errors
```
Error: Cannot find WiX toolset
Solution: Install WiX 6 from official releases
```

#### COM Harvesting Fails
```
Error: Cannot access DirectOutputComObject.dll
Solution: Ensure x86 build completed before x64, or use UpdateHarvest=true
```

#### Custom Action Missing
```
Error: Cannot find DOFSetupPBXFixup.CA.dll
Solution: Build custom action projects first, check WiX 6 DTF references
```

### Debugging
- Enable verbose logging: `/verbosity:detailed`
- Check generated files in `obj/` directory
- Verify project references build successfully
- Use `wix --help` for CLI tool options

## Next Steps

1. **Complete Testing**: Validate all installation scenarios
2. **Update CI/CD**: Modify build pipelines for WiX 6
3. **Deprecate Legacy**: Phase out WiX 3 project files
4. **Documentation**: Update user-facing installation guides

## Support

For WiX 6 specific issues:
- WiX Toolset Documentation: https://wixtoolset.org/docs/
- WiX GitHub Issues: https://github.com/wixtoolset/issues

For DirectOutput specific issues:
- Use existing project issue tracking
- Reference this migration guide for build problems