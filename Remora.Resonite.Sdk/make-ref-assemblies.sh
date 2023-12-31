#!/usr/bin/env bash

set -euf -o pipefail

declare -r SCRIPT_PATH=$(dirname $(realpath -s $0))
declare -r RESONITE_PATH="${HOME}/.steam/steam/steamapps/common/Resonite"
declare -ra RESONITE_ASSEMBLIES=(
  "Elements.Assets.dll"
  "Elements.Core.dll"
  "Elements.Quantity.dll"
  "FrooxEngine.dll"
  "FrooxEngine.Commands.dll"
  "FrooxEngine.Store.dll"
  "FrooxEngine.Weaver.dll"
  "ProtoFlux.Core.dll"
  "ProtoFlux.Nodes.Core.dll"
  "ProtoFlux.Nodes.FrooxEngine.dll"
  "ProtoFluxBindings.dll"
  "QuantityX.dll"
  "SkyFrost.Base.dll"
  "UnityFrooxEngineRunner.dll"
)

function generate_ref_assemblies() {
    for assembly in "${RESONITE_ASSEMBLIES[@]}"; do
      echo "Generating reference assembly for ${assembly}"
      dotnet refasmer \
        --all \
        --overwrite \
        --outputdir "${SCRIPT_PATH}/Sdk/ref/client" \
        "${RESONITE_PATH}/Resonite_Data/Managed/${assembly}"

      pushd "${SCRIPT_PATH}/Sdk/ref/headless" &> /dev/null
        ln -sfr "../client/${assembly}" "${assembly}"
      popd &> /dev/null
    done
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
