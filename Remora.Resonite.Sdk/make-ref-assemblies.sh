#!/usr/bin/env bash

set -euf -o pipefail

declare -r OUTPUT_PATH="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)/Sdk/ref/"
declare -r RESONITE_PATH="${HOME}/.steam/steam/steamapps/common/Resonite"
declare -ra RESONITE_ASSEMBLIES=(
  "Elements.Assets.dll"
  "Elements.Core.dll"
  "FrooxEngine.dll"
  "FrooxEngine.Commands.dll"
  "FrooxEngine.Weaver.dll"
  "ProtoFlux.Core.dll"
  "ProtoFlux.Nodes.Core.dll"
  "ProtoFlux.Nodes.FrooxEngine.dll"
  "ProtoFluxBindings.dll"
  "QuantityX.dll"
  "SkyFrost.Base.dll"
  "UnityFrooxEngineRunner.dll"
)

if ! command -v refasmer &> /dev/null; then
  echo "refasmer not found"
  exit 1
fi

echo "Resonite build version: $(cat ${RESONITE_PATH}/Build.version)"

for assembly in "${RESONITE_ASSEMBLIES[@]}"; do
  echo "Generating reference assembly for ${assembly}"
  dotnet refasmer --all --overwrite --outputdir "${OUTPUT_PATH}/client" "${RESONITE_PATH}/Resonite_Data/Managed/${assembly}"

  pushd "${OUTPUT_PATH}/headless" &> /dev/null
    ln -sfr "../client/${assembly}" "${assembly}"
  popd &> /dev/null
done
