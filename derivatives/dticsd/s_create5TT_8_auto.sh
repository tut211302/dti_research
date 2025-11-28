#!/bin/bash
# =======================================
# 5TT generation for all subjects
# =======================================

RAW_DIR="/home/brain/dti_research/preproc"
DERIV_DIR="/home/brain/dti_research/derivatives/dticsd"

# RAW_DIR内の被験者フォルダを自動検出
for subj_path in ${RAW_DIR}/sub-*; do
    SUBJECT_ID=$(basename ${subj_path})
    echo "======================================="
    echo "Running 5TT generation for ${SUBJECT_ID}"
    echo "======================================="

    SESSION_ID="ses-01"
    mkdir -p "${DERIV_DIR}/${SUBJECT_ID}"
    cd "${DERIV_DIR}/${SUBJECT_ID}"

    # ================================
    # Step 1: Copy T1w in diffusion space
    # ================================
    step_start=$(date +%s)
    echo "[Step 1/3] Copying T1-weighted image (in DWI space)..."
    cp ${RAW_DIR}/${SUBJECT_ID}/T1w_in_dwi_space_highres.nii.gz .
    step_end=$(date +%s)
    echo "Step #1 completed in $((step_end - step_start)) sec"
    echo

    # ================================
    # Step 2: Generate 5TT image using FSL segmentation
    # ================================
    step_start=$(date +%s)
    echo "[Step 2/3] Generating 5TT.mif using FSL-based segmentation..."
    5ttgen fsl T1w_in_dwi_space_highres.nii.gz 5TT.mif -nocleanup -force
    step_end=$(date +%s)
    echo "Step #2 completed in $((step_end - step_start)) sec"
    echo

    # ================================
    # Step 3: Convert for visualization
    # ================================
    step_start=$(date +%s)
    echo "[Step 3/3] Converting 5TT.mif for visualization..."
    5tt2vis 5TT.mif vis.mif -force
    step_end=$(date +%s)
    echo "Step #3 completed in $((step_end - step_start)) sec"
    echo

    echo "======================================="
    echo "5TT generation and visualization complete for ${SUBJECT_ID}"
    echo "Output directory: ${DERIV_DIR}/${SUBJECT_ID}"
    echo "======================================="
    echo

    break
done
