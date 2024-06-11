#!/usr/bin/env bash

set -eu -o pipefail

declare -r SCRIPT_PATH=$(dirname $(realpath -s $0))
declare -r RESONITE_PATH="${HOME}/.steam/steam/steamapps/common/Resonite"
declare -ra RESONITE_ASSEMBLY_GLOBS=(
  "Elements*.dll"
  "FrooxEngine*.dll"
  "ProtoFlux*.dll"
  "QuantityX.dll"
  "SkyFrost.*.dll"
  "UnityFrooxEngineRunner.dll"
)

function generate_ref_assemblies() {
    pushd "${RESONITE_PATH}/Resonite_Data/Managed" &> /dev/null
        for assembly in ${RESONITE_ASSEMBLY_GLOBS[@]}; do
            local full_path="$(realpath ${assembly})"
            pushd "${SCRIPT_PATH}" &> /dev/null
                echo "Generating reference assembly for ${assembly}"
                dotnet refasmer \
                  --all \
                  --overwrite \
                  --outputdir "${SCRIPT_PATH}/Sdk/ref/client" \
                  "${full_path}"

                pushd "${SCRIPT_PATH}/Sdk/ref/headless" &> /dev/null
                  ln -sfr "../client/${assembly}" "${assembly}"
                popd &> /dev/null
          popd &> /dev/null
        done
    popd &> /dev/null
}

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
    if ! command -v refasmer &> /dev/null; then
      echo "refasmer not found"
      exit 1
    fi

    local -r RESONITE_VERSION="$(cat ${RESONITE_PATH}/Build.version)"

    echo "Resonite build version: ${RESONITE_VERSION}"
    generate_ref_assemblies

    echo "Creating assembly version directives..."
    get_versioned_targets_contents "${RESONITE_VERSION}" | tee "${SCRIPT_PATH}/Sdk/Sdk.ResoniteVersion.targets"
}

main ${@}
