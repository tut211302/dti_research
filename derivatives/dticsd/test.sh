#!/bin/bash
# ========================================
# Automated FOD generation and iFOD2 tractography
# ========================================

RAW_DIR=/media/sf_share/MRI_MPILMBB_LEMON/MRI_Raw
PREPROC_DIR=/home/brain/dti_research/preproc
DERIV_DIR=/home/brain/dti_research/derivatives/tractography

mkdir -p $DERIV_DIR

# 被験者フォルダごとにループ
for subj_path in ${RAW_DIR}/sub-*; do
    subj_id=$(basename $subj_path)
    echo "======================================="
    echo "Processing ${subj_id}"
    echo "======================================="

    mkdir -p ${DERIV_DIR}/${subj_id}
    cd ${DERIV_DIR}/${subj_id}

    # パス設定
    DWI=${PREPROC_DIR}/${subj_id}/${subj_id}_ses-01_dir-PA_dwi_aftereddy.mif
    MASK=${PREPROC_DIR}/${subj_id}/b0_PA1_brain_mask.nii.gz

    # ================================
    # Step 1: Estimate response functions
    # ================================
    echo "[Step 1/3] Estimating response functions (dhollander)..."
    step_start=$(date +%s)
    dwi2response dhollander $DWI RF_WM.txt RF_GM.txt RF_CSF.txt -mask $MASK -voxels RF_voxels.mif
    step_end=$(date +%s)
    echo "Step 1 completed in $((step_end - step_start)) sec"
    echo

    # ================================
    # Step 2: Compute FODs (MSMT-CSD)
    # ================================
    echo "[Step 2/3] Computing FODs (MSMT-CSD)..."
    step_start=$(date +%s)
    dwi2fod msmt_csd $DWI RF_WM.txt WM_FOD.mif RF_GM.txt GM_FOD.mif RF_CSF.txt CSF_FOD.mif -mask $MASK
    step_end=$(date +%s)
    echo "Step 2 completed in $((step_end - step_start)) sec"
    echo

    # ================================
    # Step 3: Run iFOD2 tractography
    # ================================
    echo "[Step 3/3] Running iFOD2 tractography..."
    step_start=$(date +%s)
    tckgen WM_FOD.mif \
        -algorithm iFOD2 \
        -act 5TT.mif \
        -backtrack \
        -crop_at_gmwmi \
        -seed_dynamic WM_FOD.mif \
        -maxlength 250 \
        -step 0.8 \
        -select 300000 \
        -nthreads 4 \
        ${subj_id}_CSD_Prob_300k.tck -force
    step_end=$(date +%s)
    echo "Step 3 completed in $((step_end - step_start)) sec"
    echo
    break

done

echo "======================================="
echo "All subjects processed!"
echo "Output directory: $DERIV_DIR"
echo "======================================="