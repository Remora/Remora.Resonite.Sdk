Remora.Resonite.Sdk
==========

Remora.Resonite.Sdk is an MSBuild SDK made to simplify development of Resonite plugins

## Feature Highlights
* Supports both plugins and mods (via ResoniteModLoader)
* Supports the main and headless clients
* Does not require Resonite to be installed
* `dotnet publish` generates a pre-formatted .zip file, ready for release
* `dotnet build` optionally installs the artifacts to Resonite
* Easily debug right from your IDE!

## Usage
The SDK is made available via NuGet, and usage is as simple as using it in place
of the standard .NET SDK. You can also configure the project type and the target
version of Resonite you want to build content for.

```xml
<Project Sdk="Remora.Resonite.Sdk/1.0.0">
    <PropertyGroup>
        <ResoniteProjectType>mod</ResoniteProjectType>
        <ResoniteTarget>client</ResoniteTarget>
    </PropertyGroup>
</Project>
```

Note that you do not need to define the target framework(s); the SDK defaults to
the target framework that the chosen version of Resonite uses.

## Feature Breakdown
The following sections dive into each feature category that the SDK handles.
Generally, the SDK defines or implements features within each category in an
overridable or non-overridable way; non-overridable features are defined after
user definitions, and overwrite any value you set.

Properties marked with an asterisk (`*`) are defined by Remora.Resonite.Sdk and are 
not part of the standard set of properties exposed by MSBuild or 
Microsoft.NET.Sdk.

### Targeting
The following properties are defined by the SDK.

| Property         | Value  | Overridable |
|------------------|--------|-------------|
| TargetFramework  | net462 | Yes         |
| ResoniteProjectType* | mod    | Yes         |
| ResoniteTarget*      | client | Yes         |

`ResoniteProjectType` can be set to `plugin`, `mod`, `library`or `standalone`. In the case of
mods, a reference to `ResoniteModLoader` will be automatically added as well.

`ResoniteTarget` can be set to either `client` or `headless`. The latter is for the
server version of Resonite which does not have any graphics, while the former is
the normal version.

`standalone` projects build freestanding executables instead of additions to the
official Resonite clients - this can be used to build tools and utilities that
work with the Resonite ecosystem outside of direct client interaction.

### Building
The following properties are defined by the SDK.

| Property                      | Value                             | Overridable |
|-------------------------------|-----------------------------------|-------------|
| ResonitePath*                     | $(MSBuildProjectDirectory)/Resonite | Yes         |
| ResoniteInstallOnBuild*           | false                             | Yes         |
| ResoniteReferencePath*            | (internal)                        | Yes         |
| ResoniteForceReferenceAssemblies* | false                             | Yes         |

`ResonitePath` defaults to looking for a live installation of Resonite in the project
directory, and then proceeds to check common system installation paths. If you
have installed Resonite in a non-standard location, you can use this property to
configure it. It is not required for `ResonitePath` to point to a real installation;
the SDK will work just fine without one.

If `ResoniteInstallOnBuild` is set to `true`, the produced build artifacts will be 
copied to your Resonite installation directory whenever the project is built or 
published. This can be combined with an IDE and a debugger to quickly and easily
test your mod without having to go through the steps of manually moving things 
over whenever you've made modifications.

Remora.Resonite.Sdk bundles Resonite's API in the form of reference assemblies, which
enable installation-free compilation for all four supported project variants.
You can control the location where these assemblies are loaded from with 
`ResoniteReferencePath` if you don't want to use the ones bundled with the SDK.

If you do have Resonite installed, the real assemblies from the installation
directory will be preferentially chosen. If you don't want this, you can set
`ResoniteForceReferenceAssemblies` to `true` in order to disable that behaviour and 
always use the reference assemblies in `ResoniteReferencePath`.

### References
Remora.Resonite.Sdk extends the normal msbuild `PackageReference` and 
`ProjectReference` items with a third option: `ResoniteReference`. This reference 
type can be used to add references to assemblies either available through the 
reference assemblies or directly in Resonite's installation directory. For 
example, to add a reference to `BaseX`, you would simply add this to your 
project file.

```xml
<ItemGroup>
    <ResoniteReference Include="BaseX"/>
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
| RESONITE_MOD               | defined if `'$(ResoniteProjectType)' == 'mod'`                                       |
| RESONITE_PLUGIN            | defined if `'$(ResoniteProjectType)' == 'plugin'`                                    |
| RESONITE_CLIENT            | defined if `'$(ResoniteTarget)' == 'client'`                                         |
| RESONITE_HEADLESS          | defined if `'$(ResoniteTarget)' == 'headless'`                                       |
| RESONITE_BUILD_\<buildid\> | defines the Steam BuildID of the Resonite version the reference assemblies reflect |

These can be useful if you want to support both the headless and the normal 
client but need to use specialized API surfaces in either target.

### Publishing
The following properties are defined by the SDK.

| Property                   | Value                             | Overridable |
|----------------------------|-----------------------------------|-------------|
| ResoniteGenerateReleaseArchive | `'$(Configuration)' == 'Release'` | Yes         |

`dotnet publish` has been extended to both generate a proper directory structure
in the output directory, but also to create a .zip file suitable for direct 
unpacking into a Resonite installation. The archive can be uploaded as part of a 
github release or other distribution process.

You can disable this behaviour by setting `ResoniteGenerateReleaseArchive` to 
`false`.
