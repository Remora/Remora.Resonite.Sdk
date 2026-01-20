#!/usr/bin/env bash

set -eu -o pipefail

declare -r SCRIPT_PATH=$(dirname $(realpath -s $0))
declare -r RESONITE_PATH="${HOME}/.steam/steam/steamapps/common/Resonite"

function get_versioned_targets_contents() {
    local -r RESONITE_VERSION="${1}"

    cat << EOF
<!-- auto-generated -->
<Project>
    <ItemGroup>
        <AssemblyAttribute Include="System.Reflection.AssemblyMetadataAttribute">
            <_Parameter1>ResoniteVersion</_Parameter1>
            <_Parameter2>${RESONITE_VERSION}</_Parameter2>
        </AssemblyAttribute>
    </ItemGroup>
</Project>
EOF
}

function main() {
    dotnet restore

    local -r RESONITE_VERSION="$(cat ${RESONITE_PATH}/Build.version)"

    echo "Resonite build version: ${RESONITE_VERSION}"
    dotnet ReferencePackageGenerator ReferenceGeneration/Client.json ReferenceGeneration/Headless.json ReferenceGeneration/Renderite.json ReferenceGeneration/Shared.json

    echo "Creating assembly version directives..."
    get_versioned_targets_contents "${RESONITE_VERSION}" | tee "${SCRIPT_PATH}/Sdk/Sdk.ResoniteVersion.targets"
}

main ${@}
