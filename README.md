Remora.Neos.Sdk
==========
Remora.Neos.Sdk is an MSBuild SDK made to simplify development of NeosVR plugins
and mods.

## Feature Highlights
* Supports both plugins and mods (via NeosModLoader)
* Supports the main and headless clients
* Does not require NeosVR to be installed
* `dotnet publish` generates a pre-formatted .zip file, ready for release
* `dotnet build` optionally installs the artifacts to NeosVR
* Easily debug right from your IDE!

## Usage
The SDK is made available via NuGet, and usage is as simple as using it in place
of the standard .NET SDK. You can also configure the project type and the target
version of NeosVR you want to build content for.

```xml
<Project Sdk="Remora.Neos.Sdk/1.0.0">
    <PropertyGroup>
        <NeosProjectType>mod</NeosProjectType>
        <NeosTarget>client</NeosTarget>
    </PropertyGroup>
</Project>
```

Note that you do not need to define the target framework(s); the SDK defaults to
the target framework that the chosen version of NeosVR uses.

## Feature Breakdown
The following sections dive into each feature category that the SDK handles.
Generally, the SDK defines or implements features within each category in an
overridable or non-overridable way; non-overridable features are defined after
user definitions, and overwrite any value you set.

Properties marked with an asterisk (`*`) are defined by Remora.Neos.Sdk and are 
not part of the standard set of properties exposed by MSBuild or 
Microsoft.NET.Sdk.

### Targeting
The following properties are defined by the SDK.

| Property         | Value  | Overridable |
|------------------|--------|-------------|
| TargetFramework  | net462 | Yes         |
| NeosProjectType* | mod    | Yes         |
| NeosTarget*      | client | Yes         |

`NeosProjectType` can be set to `plugin`, `mod`, or `standalone`. In the case of
mods, a reference to `NeosModLoader` will be automatically added as well.

`NeosTarget` can be set to either `client` or `headless`. The latter is for the
server version of NeosVR which does not have any graphics, while the former is
the normal version.

`standalone` projects build freestanding executables instead of additions to the
official NeosVR clients - this can be used to build tools and utilities that
work with the NeosVR ecosystem outside of direct client interaction.

### Building
The following properties are defined by the SDK.

| Property                      | Value                             | Overridable |
|-------------------------------|-----------------------------------|-------------|
| NeosPath                      | $(MSBuildProjectDirectory)/NeosVR | Yes         |
| NeosInstallOnBuild*           | false                             | Yes         |
| NeosReferencePath*            | (internal)                        | Yes         |
| NeosForceReferenceAssemblies* | false                             | Yes         |

`NeosPath` defaults to looking for a live installation of NeosVR in the project
directory, and then proceeds to check common system installation paths. If you
have installed NeosVR in a non-standard location, you can use this property to
configure it. It is not required for `NeosPath` to point to a real installation;
the SDK will work just fine without one.

If `NeosInstallOnBuild` is set to `true`, the produced build artifacts will be 
copied to your NeosVR installation directory whenever the project is built or 
published. This can be combined with an IDE and a debugger to quickly and easily
test your mod without having to go through the steps of manually moving things 
over whenever you've made modifications.

Remora.Neos.Sdk bundles NeosVR's API in the form of reference assemblies, which
enable installation-free compilation for all four supported project variants.
You can control the location where these assemblies are loaded from with 
`NeosReferencePath` if you don't want to use the ones bundled with the SDK.

If you do have NeosVR installed, the real assemblies from the installation
directory will be preferentially chosen. If you don't want this, you can set
`NeosForceReferenceAssemblies` to `true` in order to disable that behaviour and 
always use the reference assemblies in `NeosReferencePath`.

### References
Remora.Neos.Sdk extends the normal msbuild `PackageReference` and 
`ProjectReference` items with a third option: `NeosReference`. This reference 
type can be used to add references to assemblies either available through the 
reference assemblies or directly in NeosVR's installation directory. For 
example, to add a reference to `BaseX`, you would simply add this to your 
project file.

```xml
<ItemGroup>
    <NeosReference Include="BaseX"/>
</ItemGroup>
```

`PackageReference` items are also fully supported, meaning you can use any 
compatible library on nuget when developing your project. The required 
assemblies will be copied to the appropriate directory depending on your project
type.

### Compile-time Constants
The SDK also defines a set of compile-time constants which you can use if your 
project needs to know certain information about the target environment it's 
being compiled for.

| Name                     | Description                                                                      |
|--------------------------|----------------------------------------------------------------------------------|
| NEOSVR_MOD               | defined if `'$(NeosProjectType)' == 'mod'`                                       |
| NEOSVR_PLUGIN            | defined if `'$(NeosProjectType)' == 'plugin'`                                    |
| NEOSVR_CLIENT            | defined if `'$(NeosTarget)' == 'client'`                                         |
| NEOSVR_HEADLESS          | defined if `'$(NeosTarget)' == 'headless'`                                       |
| NEOSVR_BUILD_\<buildid\> | defines the Steam BuildID of the NeosVR version the reference assemblies reflect |

These can be useful if you want to support both the headless and the normal 
client but need to use specialized API surfaces in either target.

### Publishing
The following properties are defined by the SDK.

| Property                   | Value                             | Overridable |
|----------------------------|-----------------------------------|-------------|
| NeosGenerateReleaseArchive | `'$(Configuration)' == 'Release'` | Yes         |

`dotnet publish` has been extended to both generate a proper directory structure
in the output directory, but also to create a .zip file suitable for direct 
unpacking into a NeosVR installation. The archive can be uploaded as part of a 
github release or other distribution process.

You can disable this behaviour by setting `NeosGenerateReleaseArchive` to 
`false`.
