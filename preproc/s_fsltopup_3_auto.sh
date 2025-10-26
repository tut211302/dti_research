#!/bin/bash

RAW_DIR=/home/brain/research/DATA/BIDS/raw
PREPROC_DIR=/home/brain/research/DATA/BIDS/preproc

# RAW_DIR内の被験者フォルダを自動検出
for subj_path in ${RAW_DIR}/sub-*; do
    subj_id=$(basename ${subj_path})
    echo "===== Processing ${subj_id} ====="

    mkdir -p ${PREPROC_DIR}/${subj_id}
    cd ${PREPROC_DIR}/${subj_id}

    # ================================
    # Step 1: Extract b=0 images from b=0 data
    # ================================
    step_start=$(date +%s)
    # PA
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_1.nii.gz 0 1
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_2.nii.gz 1 1
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_3.nii.gz 2 1

    # AP
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_1.nii.gz 0 1
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_2.nii.gz 1 1
    fslroi ${subj_path}/ses-01/fmap/${subj_id}_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_3.nii.gz 2 1
    step_end=$(date +%s)
    echo "Step #1 completed in $((step_end - step_start)) sec"
    echo
    # ================================
    # Step 2: Merge b=0 files into a single NIfTI
    # ================================
    step_start=$(date +%s)
    fslmerge -t APPAb0_all.nii.gz \
        b0_AP_1.nii.gz b0_AP_2.nii.gz b0_AP_3.nii.gz \
        b0_PA_1.nii.gz b0_PA_2.nii.gz b0_PA_3.nii.gz
    step_end=$(date +%s)
    echo "Step #2 completed in $((step_end - step_start)) sec"
    echo

    # ================================
    # Step 3: Run TOPUP
    # ================================
    echo "Running TOPUP for ${subj_id} ..."
    step_start=$(date +%s)
    topup --imain=APPAb0_all.nii.gz \
          --datain=${PREPROC_DIR}/acquisition_parameters.txt \
          --config=${PREPROC_DIR}/b02b0download.cnf \
          --out=topup_PA_AP_b0 \
          --fout=field \
          --iout=unwarped_images
    step_end=$(date +%s)
    echo "Step #3 completed in $((step_end - step_start)) sec"
    echo

    echo "Finished TOPUP for ${subj_id}"
done
