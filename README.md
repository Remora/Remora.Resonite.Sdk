Remora.Resonite.Sdk
===================

`Remora.Resonite.Sdk` is an `MSBuild` SDK made to simplify the development of
various kinds of software targeting Resonite.


## Feature Highlights

* Supports various mod loaders
    * [MonkeyLoader](https://github.com/ResoniteModdingGroup/MonkeyLoader.GamePacks.Resonite)
    * [ResoniteModLoader](https://github.com/resonite-modding-group/ResoniteModLoader)
    * [BepisLoader](https://github.com/ResoniteModding/BepisLoader)
* Supports the creation of general libraries, mods, plugins, and standalone applications
* Supports targeting the main / headless clients, and Renderite
* Does not require Resonite to be installed - perfect for CI
* `dotnet publish` generates a pre-formatted .zip file, ready for release
* `dotnet build` optionally installs the artifacts to Resonite
* Easily debug right from your IDE!


## Usage

The SDK is made available via NuGet, and usage is as simple as using it in place
of the standard .NET SDK. You can also configure the project type and the target
version of Resonite you want to build content for.

```xml
<Project Sdk="Remora.Resonite.Sdk/2.x.y">
    <PropertyGroup>
        <ResoniteTarget>headless</ResoniteTarget>
        <ResoniteProjectType>plugin</ResoniteProjectType>
    </PropertyGroup>
</Project>
```

Note that you do not need to define the target framework(s); the SDK defaults to
the target framework that the chosen version of Resonite uses.  
Specifying the version in the project file is optional too.
Particularly for solutions with multiple projects using the SDK,
it's advisable to add a global.json with the following content:

```json
{
    "msbuild-sdks": {
        "Remora.Resonite.Sdk": "2.x.y"
    }
}
```

Of course, the proper version number must be specified.
Simply check for the version of the latest release here or on the NuGet feed you're using.


## Feature Breakdown

The following sections dive into each feature category that the SDK handles.
Generally, the SDK defines or implements features within each category in an
overridable or non-overridable way; non-overridable features are defined after
user definitions, and overwrite any value you set.

Properties marked with an asterisk (`*`) are part of the standard set of
properties exposed by `MSBuild` or the `Microsoft.NET.Sdk` that get
defined by `Remora.Resonite.Sdk`.


### Targeting

The following properties are defined by the SDK.

| Property                    | Value                                                                      | Overridable |
|-----------------------------|----------------------------------------------------------------------------|-------------|
| ResoniteTarget              | client                                                                     | Yes         |
| ResoniteProjectType         | mod                                                                        | Yes         |
| ResoniteTargetModLoader     | MonkeyLoader                                                               | Yes         |
| TargetFramework*            | net10.0 / net472                                                           | Yes         |
| ResoniteUseMonkeyLoaderCore | `'$(ResoniteProjectType)' == 'mod' AND '$(ResoniteTarget)' != 'renderite'` | Yes         |

`ResoniteTarget` can be set to `client`, `headless`, or `renderite`.  
`headless` is for the server version of Resonite which does not have any graphics,
while `client` is for the normal version. Which one of these two is chosen is generally
not important, unless targeting their launch executables in particular.  
`renderite` on the other hand is for the Unity-based renderer that the `client` uses.
It has none of the typical Resonite / FrooxEngine contents and is only concerned
with getting everything received through the interprocess communication rendered.

`ResoniteProjectType` can be set to `mod`, `plugin`, `library` or `standalone`.  
In the case of `mod`s, any necessary references for the chosen `ResoniteTargetModLoader`
will be added automatically as well.
`plugins` are intended to be loaded by the `client` or `headless` through
the `-LoadAssembly` commandline arguments, while `library` projects are
intended for general purpose projects that may be used by any of the others.
`standalone` projects build freestanding executables instead of additions to the
official Resonite clients - this can be used to build tools and utilities that
work with the Resonite ecosystem outside of direct client interaction.

`ResoniteTargetModLoader` can be set to `MonkeyLoader`, `BepisLoader`,
`ResoniteModLoader` or `ResoniteModLoaderStandalone`.  
For `MonkeyLoader` and `BepisLoader`, all `ResoniteTarget`s are supported,
with the right references being chosen automatically,
while the two `ResoniteModLoader` options only support `client` or `headless`.  
Here, `ResoniteModLoader` refers to the
[MonkeyLoader Compatibility Pack](https://github.com/ResoniteModdingGroup/MonkeyLoader.GamePacks.ResoniteModLoader),
while `ResoniteModLoaderStandalone` refers to the version used through `-LoadAssembly`.
For maximum compatibility, `ResoniteModLoader` should be used as the target.

`TargetFramework` determines which version of .NET (Framework) a project is built for.
For a `ResoniteTarget` of `client` or `headless`, this must be `net10.0`,
while for `renderite`, `net472` is generally required.
`standalone` projects may target a higher version though.

`ResoniteUseMonkeyLoaderCore` decides whether the `MonkeyLoader.Resonite.Core`
NuGet package will be referenced when creating a mod not targeting MonkeyLoader.
This package offers convenient extension methods and other features for mods,
but doesn't rely on MonkeyLoader being present.


### Building

The following properties are defined by the SDK.

| Property                         | Value                               | Overridable |
|----------------------------------|-------------------------------------|-------------|
| ResonitePath                     | $(MSBuildProjectDirectory)/Resonite | Yes         |
| ResoniteInstallOnBuild           | false                               | Yes         |
| ResoniteForceReferenceAssemblies | false                               | Yes         |
| ResoniteUsePublicizedAssemblies  | `'$(ResoniteProjectType)' == 'mod'` | Yes         |
| ResoniteReferencePath            | (internal)                          | Yes         |

`ResonitePath` defaults to looking for a live installation of Resonite in the project
directory, and then proceeds to check common system installation paths. If you
have installed Resonite in a non-standard location, you can use this property to
configure it. It is not required for `ResonitePath` to point to a real installation;
the SDK will work just fine without one.

If `ResoniteInstallOnBuild` is set to `true`, the produced build artifacts will be 
copied to the right place in your Resonite installation directory whenever
the project is built or published.
This can be combined with an IDE and a debugger to quickly and easily
test your mod without having to go through the steps of manually moving things 
over whenever you've made modifications.

If you do have Resonite installed, the real assemblies from the installation
directory will be preferentially chosen when possible.
If you don't want this, you can set `ResoniteForceReferenceAssemblies` to `true`
in order to disable that behaviour and always use the reference assemblies in `ResoniteReferencePath`.  
See the References section for how to override this behavior for individual references.

For anything but mods, the real assemblies or the stripped reference assemblies
bundled with the SDK are used by default. When creating mods however, or when
`ResoniteUsePublicizedAssemblies` is manually overridden to `true`,
publicized versions of the reference assemblies will be used instead.
This allows unrestricted access to all types and their members in all assemblies,
rather than having to use slow reflection or injections to access them.  
See the References section for how to override this behavior for individual references.

Remora.Resonite.Sdk bundles Resonite's API in the form of reference assemblies, which
enable installation-free compilation for all four supported project variants.
You can control the location where these assemblies are loaded from with 
`ResoniteReferencePath` if you don't want to use the ones bundled with the SDK.


### MonkeyLoader

When using `MonkeyLoader` as the `ResoniteTargetModLoader`,
there is additional properties defined by the SDK.

| Property                | Value          | Overridable |
|-------------------------|----------------|-------------|
| IsMonkeyLoaderGamePack  | false          | Yes         |
| MonkeyLoaderPackageType | Mod / GamePack | No          |
| GeneratePackageOnBuild* | true           | No          |

Most importantly, `IsMonkeyLoaderGamePack` controls whether the packed project
is placed into the `MonkeyLoader/Mods/` or `MonkeyLoader/GamePacks/` directory,
if `ResoniteInstallOnBuild` is set to `true`.

To ensure that a NuGet package is created, the `MSBuild` property
`GeneratePackageOnBuild` is always set to `true`.


### Compilation

The SDK defines some defaults for properties that control the compiler settings.

| Property                   | Value    | Overridable |
|----------------------------|----------|-------------|
| LangVersion*               | 14.0     | Yes         |
| Nullable*                  | enable   | Yes         |
| Deterministic*             | true     | Yes         |
| DebugType*                 | portable | Yes         |
| ImplicitUsings*            | enable   | Yes         |
| GenerateDocumentationFile* | true     | Yes         |

These enable the latest features of the compiler and
ensure that the produced artifacts are suitable for all platforms.  
To support most of the modern language features even when targetting `renderite`,
the [PolySharp](https://github.com/Sergio0694/PolySharp) package is referenced in that case.


### NuGet Packaging

For convenience, the SDK also defines some defaults for other properties
related to NuGet packaging.

| Property                                           | Value     | Overridable |
|----------------------------------------------------|-----------|-------------|
| RepositoryType*                                    | git       | Yes         |
| IncludeSymbols*                                    | false     | Yes         |
| EmbedAllSources*                                   | true      | Yes         |
| EmbedUntrackedSources*                             | true      | Yes         |
| SymbolPackageFormat*                               | snupkg    | Yes         |
| AllowedOutputExtensionsInPackageBuildOutputFolder* | ...; .pdb | Yes         |

Together with the compilation settings above,
these ensure a consistently high quality of the generated packages.


### References

The `Remora.Resonite.Sdk` extends the normal `PackageReference` and 
`ProjectReference` items of `MSBuild` with a third option: `ResoniteReference`.
This reference type can be used to add references to assemblies either available through
the bundled reference assemblies or directly in Resonite's installation directory.
For example, to add a reference to `FrooxEngine`, you would simply add this to your 
project file:

```xml
<ItemGroup>
    <ResoniteReference Include="FrooxEngine"/>
</ItemGroup>
```

Additionally, you can set `UseReference` and `UsePublicized` as extra
metadata on the `ResoniteReference` items.
By default, they are set from `ResoniteForceReferenceAssemblies` and
`ResoniteUsePublicizedAssemblies` respectively, but they can be overridden this way.
This allows exact control over which assemblies are used for which references.
When `UsePublicized` is set, `UseReference` is ignored,
as the publicized assemblies are always references only.

`PackageReference` items are also fully supported, meaning you can use any 
compatible library on NuGet when developing your project.
The required assemblies will be copied to the appropriate directory
depending on your project type.


### Compile-time Constants

The SDK also defines a set of compile-time constants which you can use if your 
project needs to know certain information about the target environment it's 
being compiled for.

| Name                    | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| RESONITE_CLIENT         | defined if `'$(ResoniteTarget)' == 'client'`                                |
| RESONITE_HEADLESS       | defined if `'$(ResoniteTarget)' == 'headless'`                              |
| RESONITE_RENDERITE      | defined if `'$(ResoniteTarget)' == 'renderite'`                             |
| RESONITE_MOD            | defined if `'$(ResoniteProjectType)' == 'mod'`                              |
| RESONITE_PLUGIN         | defined if `'$(ResoniteProjectType)' == 'plugin'`                           |
| RESONITE_LIBRARY        | defined if `'$(ResoniteProjectType)' == 'library'`                          |
| RESONITE_STANDALONE     | defined if `'$(ResoniteProjectType)' == 'standalone'`                       |
| RESONITE_MONKEYLOADER   | defined if `'$(ResoniteTargetModLoader)' == 'MonkeyLoader'`                 |
| RESONITE_BEPISLOADER    | defined if `'$(ResoniteTargetModLoader)' == 'BepisLoader'`                  |
| RESONITE_RML            | defined if `'$(ResoniteTargetModLoader)' == 'ResoniteModLoader*'`           |
| RESONITE_RML_STANDALONE | defined if `'$(ResoniteTargetModLoader)' == 'ResoniteModLoaderStandalone'`  |

These can be useful if you want to support both the headless and the normal 
client but need to use specialized API surfaces in either target,
or if you want to build a library that interacts with multiple mod loaders.


# Assembly Attributes

Since knowing the Resonite version something was built against can be useful in
several instances, the version is embedded into your assemblies as an assembly attribute.

No matter your project type, the following attributes are always defined.

| Name             | Parameters                                          |
|------------------|-----------------------------------------------------|
| AssemblyMetadata | Key = "ResoniteVersion", Value = "$CURRENT_VERSION" |

Additionally, for each `ResoniteReference` with `UsePublicized` set to `true`,
a corresponding `IgnoreAccessChecksTo` attribute is added.
This ensures that there will be no issues when accessing non-public types or
members of those assemblies at runtime.


### Publishing

The following properties are defined by the SDK.

| Property                       | Value                             | Overridable |
|--------------------------------|-----------------------------------|-------------|
| ResoniteGenerateReleaseArchive | `'$(Configuration)' == 'Release'` | Yes         |

`dotnet publish` has been extended to both generate a proper directory structure
in the output directory, but also to create a .zip file suitable for direct 
unpacking into a Resonite installation. The archive can be uploaded as part of a 
GitHub release or other distribution process.

You can disable this behaviour by setting `ResoniteGenerateReleaseArchive` to `false`.


## Known Issues

The BepisLoader integration doesn't currently support automatic installation.
We'll gladly accept any PRs for that.


## License

This SDK itself is licensed as LGPL-3.0 - but projects using it may have any license they choose.