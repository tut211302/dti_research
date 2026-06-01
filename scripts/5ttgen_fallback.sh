#!/usr/bin/env bash
# Simple fallback wrapper for mrtrix3 `5ttgen`.
# Usage: scripts/5ttgen_fallback.sh <T1_in_dwi_space.nii.gz> <out_prefix> [log_dir]
# Tries backends in order: hsvs -> gif -> freesurfer -> fsl

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <T1_in_dwi_space.nii.gz> <out_prefix> [log_dir]" >&2
  exit 2
fi

T1_IN="$1"
OUT_PREFIX="$2"
LOG_DIR="${3:-./logs/5ttgen_fallback}"

mkdir -p "${LOG_DIR}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_BASENAME=$(basename "${OUT_PREFIX}")
LOG_BASE="${LOG_DIR}/5ttgen_${OUT_BASENAME}_${TIMESTAMP}"

BACKENDS=(hsvs gif freesurfer fsl)

echo "5ttgen fallback starting: input=${T1_IN}, out=${OUT_PREFIX}, logs=${LOG_DIR}"

for b in "${BACKENDS[@]}"; do
  OUT="${OUT_PREFIX}_${b}.mif"
  STDOUT_LOG="${LOG_BASE}_${b}.out"
  STDERR_LOG="${LOG_BASE}_${b}.err"

  echo "Trying backend: ${b} -> output: ${OUT}"

  # Build command
  CMD=(5ttgen "${b}" "${T1_IN}" "${OUT}" -force)

  # Run and capture logs
  if "${CMD[@]}" >"${STDOUT_LOG}" 2>"${STDERR_LOG}"; then
    echo "SUCCESS: backend=${b} produced ${OUT}" | tee -a "${LOG_BASE}.summary"
    echo "stdout -> ${STDOUT_LOG}" >> "${LOG_BASE}.summary"
    echo "stderr -> ${STDERR_LOG}" >> "${LOG_BASE}.summary"
    # Optionally create a symlink to the chosen output
    ln -sf "${OUT}" "${OUT_PREFIX}.mif"
    exit 0
  else
    echo "FAIL: backend=${b} (logs: ${STDOUT_LOG}, ${STDERR_LOG})" | tee -a "${LOG_BASE}.summary"
    # continue to next backend
  fi
done

echo "ALL_BACKENDS_FAILED: No 5TT generated for ${T1_IN}. See ${LOG_BASE}.summary" >&2
exit 1
