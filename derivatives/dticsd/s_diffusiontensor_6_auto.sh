#!/bin/bash
# ========================================
# DTI tensor fitting & metrics for all subjects
# ========================================

# ディレクトリ設定
RAW_DIR="/home/brain/dti_research/preproc"
DERIV_DIR="/home/brain/dti_research/derivatives/dticsd"

mkdir -p ${DERIV_DIR}

echo "===== DTI Processing Started: $(date) ====="

# RAW_DIR内の被験者フォルダを自動検出
for subj_path in ${RAW_DIR}/sub-*; do
    subj_id=$(basename ${subj_path})
    echo "===== Processing ${subj_id} ====="

    # 出力ディレクトリを作成
    mkdir -p ${DERIV_DIR}/${subj_id}
    cd ${DERIV_DIR}/${subj_id}

    # 入力ファイルパス設定
    dwi_file="${RAW_DIR}/${subj_id}/${subj_id}_ses-01_dir-PA_dwi_aftereddy.mif"
    mask_file="${RAW_DIR}/${subj_id}/b0_1_PA_aftereddy_brain_mask.nii.gz"

    # 出力ファイル設定
    dt_file="${DERIV_DIR}/${subj_id}/${subj_id}_dt_PA.mif"
    fa_file="${DERIV_DIR}/${subj_id}/${subj_id}_FA_PA.mif"
    ad_file="${DERIV_DIR}/${subj_id}/${subj_id}_AD_PA.mif"
    rd_file="${DERIV_DIR}/${subj_id}/${subj_id}_RD_PA.mif"
    md_file="${DERIV_DIR}/${subj_id}/${subj_id}_MD_PA.mif"
    pdd_file="${DERIV_DIR}/${subj_id}/${subj_id}_PDD_PA.mif"

    # DWIファイルとマスクの存在確認
    if [[ ! -f "${dwi_file}" ]]; then
        echo "DWI file not found: ${dwi_file}"
        continue
    fi
    if [[ ! -f "${mask_file}" ]]; then
        echo "Mask file not found: ${mask_file}"
        continue
    fi

    # Step #1: Tensor fitting
    step_start=$(date +%s)
    echo "  → Running dwi2tensor..."
    dwi2tensor "${dwi_file}" "${dt_file}" -mask "${mask_file}"
    step_end=$(date +%s)
    echo "Step #1 completed in $((step_end - step_start)) sec"
    echo

    # Step #2: Compute tensor metrics
    step_start=$(date +%s)
    echo "  → Running tensor2metric..."
    tensor2metric -fa "${fa_file}" -ad "${ad_file}" -rd "${rd_file}" -adc "${md_file}" -vector "${pdd_file}" "${dt_file}"
    step_end=$(date +%s)
    echo "Step #2 completed in $((step_end - step_start)) sec"
    echo

    echo "${subj_id} completed."

    break
done



echo "===== DTI Processing Finished: $(date) ====="
