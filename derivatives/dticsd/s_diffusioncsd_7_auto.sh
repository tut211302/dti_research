#!/bin/bash
# ========================================
# MSMT-CSD FOD estimation for all subjects
# ========================================

# ディレクトリ設定
DATA_DIR="/home/brain/dti_research/preproc/"
DERIV_DIR="/home/brain/dti_research/derivatives/dticsd"


echo "===== MSMT-CSD Processing Started: $(date) ====="

# 被験者フォルダを自動検出
for subj_path in ${DATA_DIR}/sub-*; do
    SUBJ_ID=$(basename ${subj_path})
    echo "===== Processing ${SUBJ_ID} ====="

    # 出力ディレクトリ作成
    OUT_DIR=${DERIV_DIR}/${SUBJ_ID}
    mkdir -p ${OUT_DIR}
    cd ${OUT_DIR}

    # ------------------------
    # Step 1: Estimate response function
    # ------------------------
    step_start=$(date +%s)
    dwi2response dhollander \
        ${DATA_DIR}/${SUBJ_ID}/${SUBJ_ID}_ses-01_dir-PA_dwi_aftereddy.mif \
        RF_WM_PA.txt RF_GM_PA.txt RF_CSF_PA.txt \
        -mask ${DATA_DIR}/${SUBJ_ID}/b0_1_PA_aftereddy_brain_mask.nii.gz \
        -voxels RF_voxels_PA.mif
    step_end=$(date +%s)
    echo "Step #1 completed in $((step_end - step_start)) sec"

    # ------------------------
    # Step 2: Estimate FODs using MSMT-CSD
    # ------------------------
    step_start=$(date +%s)
    dwi2fod msmt_csd \
        ${DATA_DIR}/${SUBJ_ID}/${SUBJ_ID}_ses-01_dir-PA_dwi_aftereddy.mif \
        RF_WM_PA.txt WM_FOD_PA.mif \
        RF_GM_PA.txt GM_FOD_PA.mif \
        RF_CSF_PA.txt CSF_FOD_PA.mif \
        -mask ${DATA_DIR}/${SUBJ_ID}/b0_1_PA_aftereddy_brain_mask.nii.gz
    step_end=$(date +%s)
    echo "Step #2 completed in $((step_end - step_start)) sec"

    echo "===== Finished ${SUBJ_ID} ====="
done

echo "===== MSMT-CSD Processing Completed: $(date) ====="
