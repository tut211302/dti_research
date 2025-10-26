#!/bin/bash

RAW_DIR=/media/sf_share/MRI_MPILMBB_LEMON/MRI_Raw
PREPROC_DIR=/home/brain/dti_research/preproc

# RAW_DIR内の被験者フォルダを自動検出
for subj_path in ${RAW_DIR}/sub-*; do
    # フォルダ名から被験者IDを取得
    subj_id=$(basename ${subj_path})
    echo "Processing ${subj_id} ..."

    # preprocフォルダ作成
    mkdir -p ${PREPROC_DIR}/${subj_id}
    cd ${PREPROC_DIR}/${subj_id}

    # ================================
    # Step 4: performing BET on b=0 image
    # ================================
    # BET & EDDY
    step_start=$(date +%s)
    bet b0_PA_1 b0_PA1_brain -m -f 0.2
    #bet unwarped_images_mean.nii.gz mean_b0_brain -m -f 0.2
    nvols=$(fslval ${subj_path}/ses-01/dwi/${subj_id}_ses-01_dwi.nii.gz dim4)
    #nvols=$(fslval ${PREPROC_DIR}/${subj_id}/unwarped_images.nii.gz dim4)
    yes 4 | head -n $nvols > index_PA.txt
    step_end=$(date +%s)
    echo "Step #4 completed in $((step_end - step_start)) sec"
    echo
    # ================================
    # Step 5: running EDDY on PA data
    # ================================
     
    step_start=$(date +%s)

    #--imain=${PREPROC_DIR}/${subj_id}/unwarped_images.nii.gz \
    #         --mask=mean_b0_brain_mask.nii.gz \
    eddy_cpu --imain=${subj_path}/ses-01/dwi/${subj_id}_ses-01_dwi.nii.gz \
             --mask=b0_PA1_brain_mask.nii.gz \
             --index=index_PA.txt \
             --acqp=${PREPROC_DIR}/acquisition_parameters.txt \
             --bvecs=${subj_path}/ses-01/dwi/${subj_id}_ses-01_dwi.bvec \
             --bvals=${subj_path}/ses-01/dwi/${subj_id}_ses-01_dwi.bval \
             --fwhm=0 \
             --topup=topup_PA_AP_b0 \
             --flm=quadratic \
             --out=${subj_id}_ses-01_dir-PA_dwi_aftereddy
    step_end=$(date +%s)
    echo "Step #5 completed in $((step_end - step_start)) sec"
    echo

    echo "Finished EDDY ${subj_id}"

    break
done

