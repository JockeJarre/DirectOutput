# DirectOutput Project - GitHub Copilot Instructions

## Project Overview

DirectOutput is a comprehensive pinball cabinet output control system that interfaces with various hardware devices like LEDs, solenoids, motors, and other output devices. The project is primarily written in C# with .NET Framework 4.8, includes C++/CLI components, VB.NET COM objects, and uses the WiX installer for packaging and deployment.

## Architecture & Components

### Core Components

- **DirectOutput**: Main library and application (C# .NET Framework 4.8)
- **B2SServerPlugin**: Plugin for B2S Server integration
- **DirectOutputComObject**: COM object for external application integration (VB.NET)
- **ProPinballBridge**: C++/CLI bridge for Pro Pinball integration
- **GlobalConfigEditor**: Configuration editor GUI
- **WiX Installers**: MSI installer packages using WiX Toolset v3.14

### Key Technologies

- **.NET Framework 4.8**: Primary framework for C# projects
- **C++/CLI**: For native code integration (ProPinballBridge)
- **VB.NET**: COM object implementation
- **WiX Toolset v3.14**: MSI installer creation
- **GitHub Actions**: CI/CD pipeline with matrix builds (x86/x64)

## Coding Standards & Patterns

### C# Guidelines

- Use .NET Framework 4.8 patterns and conventions
- Follow Microsoft naming conventions (PascalCase for public members, camelCase for private)
- Use proper exception handling with specific exception types
- Implement IDisposable pattern for resource management
- Use async/await patterns where appropriate for I/O operations

### Project Structure

```
DirectOutput/               # Main library
├── Cab/                   # Cabinet hardware abstractions
├── Config/                # Configuration management
├── FX/                    # Effects and animations
├── General/               # Utility classes
├── GlobalConfiguration/   # Global settings
├── LedControl/           # LED control systems
├── PinballSupport/       # Pinball table integration
└── Table/                # Table-specific functionality
```

### Hardware Integration Patterns

- Use factory patterns for hardware device creation
- Implement observer pattern for event handling
- Use dependency injection for hardware abstractions
- Always implement proper resource disposal for hardware connections

## Build System

### MSBuild Configuration

- **Platform Targets**: x86, x64 (AnyCPU not used due to hardware dependencies)
- **Configurations**: Debug, Release
- **Output Path**: `bin\$(Platform)\$(Configuration)`
- **Cross-compilation**: Avoided for WiX projects (32-bit toolset limitation)

### GitHub Actions Workflow

- **Matrix Builds**: Separate x86/x64 builds
- **Conditional Building**: Full solution for x86, individual projects for x64
- **Artifact Separation**: ZIP packages for binaries, MSI for installers
- **Version Management**: Extracted from AssemblyInfo, includes build number and commit hash

### Dependencies

- **NuGet Packages**: System.Reflection.Metadata, ManagedBass, Newtonsoft.Json
- **Native Libraries**: ledwiz32.dll, ledwiz64.dll
- **COM Registration**: DirectOutputComObject requires TLB generation
- **WiX Dependencies**: Custom actions and COM object harvesting

## Version Management

### Assembly Versioning

- **Base Version**: Extracted from `AssemblyInfo/SharedAssemblyInfo.cs`
- **Build Version**: `{Major}.{Minor}.{BuildNumber}.0`
- **Informational Version**: `{Major}.{Minor}.{BuildNumber}.0-{CommitHash}`
- **File Version**: Matches assembly version

### Release Naming

- **ZIP Packages**: `DirectOutput-release-{platform}-{date}.zip`
- **MSI Installers**: `DirectOutput-{platform}-Release-{date}-{commit}.msi`

## Hardware Device Patterns

### Device Implementation

When implementing new hardware devices:

1. Inherit from appropriate base classes in `DirectOutput.Cab.Out`
2. Implement `IOutputController` interface
3. Use proper resource disposal patterns
4. Handle hardware connection failures gracefully
5. Implement device-specific configuration classes

### Configuration System

- Use XML serialization for configuration persistence
- Implement validation in configuration classes
- Support both global and table-specific configurations
- Use property change notifications where appropriate

## Testing Patterns

### Unit Testing

- Use MSTest framework for unit tests
- Mock hardware dependencies using interfaces
- Test configuration serialization/deserialization
- Validate error handling scenarios

### Integration Testing

- Test actual hardware connections when available
- Validate complete configuration workflows
- Test plugin integration scenarios

## Common Patterns & Practices

### Error Handling

```csharp
try
{
    // Hardware operation
}
catch (SpecificHardwareException ex)
{
    Log.Exception("Specific hardware error", ex);
    // Handle gracefully
}
catch (Exception ex)
{
    Log.Exception("Unexpected error in operation", ex);
    throw; // Re-throw if cannot handle
}
```

### Resource Management

```csharp
public class HardwareDevice : IOutputController, IDisposable
{
    private bool disposed = false;
    
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
    
    protected virtual void Dispose(bool disposing)
    {
        if (!disposed && disposing)
        {
            // Clean up managed resources
            disposed = true;
        }
    }
}
```

### Configuration Classes

```csharp
[Serializable]
public class DeviceConfig
{
    public string Name { get; set; } = "";
    public int DeviceId { get; set; } = -1;
    
    public bool IsValid()
    {
        return !string.IsNullOrEmpty(Name) && DeviceId >= 0;
    }
}
```

## Development Environment

### Required Tools

- **Visual Studio 2022**: With C++/CLI and VB.NET support
- **WiX Toolset v3.14**: For MSI installer development
- **.NET Framework 4.8 SDK**: Target framework
- **Git**: Version control with conventional commits

### Debugging

- Use conditional compilation for debug output
- Implement comprehensive logging throughout the application
- Use hardware simulators when physical devices unavailable
- Test with various pinball software configurations

## COM Object Development (VB.NET)

### Registration

- Use `RegAsm.exe` for COM registration
- Generate type library (.tlb) files for external access
- Handle cross-architecture registration (x86/x64)
- Implement proper error handling in COM methods

### Interface Design

```vb
<ComVisible(True)>
<Guid("GUID-HERE")>
<InterfaceType(ComInterfaceType.InterfaceIsDual)>
Public Interface IDirectOutputComObject
    Sub Init()
    Sub Finish()
    ' Other methods
End Interface
```

## Performance Considerations

### Real-time Requirements

- Minimize allocations in hot paths
- Use object pooling for frequently created objects
- Implement efficient data structures for hardware state
- Profile hardware communication timing

### Memory Management

- Monitor memory usage with hardware drivers
- Implement proper cleanup in dispose patterns
- Use weak references where appropriate for event handlers
- Profile for memory leaks during long-running sessions

## Security Considerations

- Validate all external inputs (table configurations, ROM files)
- Handle file system access securely
- Implement proper error messages without exposing internals
- Use appropriate permissions for hardware device access

## Contributing Guidelines

### Code Reviews

- Ensure hardware compatibility across supported devices
- Verify configuration serialization works correctly
- Test with various pinball software configurations
- Validate error handling and logging

### Documentation

- Update inline documentation for public APIs
- Maintain hardware compatibility matrices
- Document configuration file formats
- Keep installation instructions current

This file should help GitHub Copilot understand the DirectOutput project structure, patterns, and conventions to provide more accurate and helpful suggestions.
