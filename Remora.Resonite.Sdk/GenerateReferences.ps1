$resoniteVersion = Get-Content -Path "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Resonite\\Build.version" -Raw

Write-Output "Resonite build version: $resoniteVersion"
dotnet ReferencePackageGenerator ReferenceGeneration/Client.json ReferenceGeneration/Headless.json ReferenceGeneration/Renderite.json ReferenceGeneration/Shared.json

Write-Output "Creating assembly version directives..."
@"
<!-- auto-generated -->
<Project>
    <ItemGroup>
        <AssemblyAttribute Include="System.Reflection.AssemblyMetadataAttribute">
            <_Parameter1>ResoniteVersion</_Parameter1>
            <_Parameter2>$resoniteVersion</_Parameter2>
        </AssemblyAttribute>
    </ItemGroup>
</Project>
"@ | Out-File -Encoding UTF8 -FilePath "Sdk/Sdk.ResoniteVersion.targets"