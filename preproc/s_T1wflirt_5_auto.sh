#!/bin/bash

# データディレクトリ
RAW_DIR=/home/brain/research/DATA/BIDS/raw
PREPROC_DIR=/home/brain/research/DATA/BIDS/preproc

mkdir -p $PREPROC_DIR
cd $PREPROC_DIR

# RAW_DIR 内の被験者ディレクトリをループ
for subdir in $RAW_DIR/sub-*; do
    sub=$(basename $subdir)
    echo "=============================="
    echo "Processing subject: $sub"
    echo "=============================="

    # ファイルパス
    DWI_FILE=$subdir/ses-01/dwi/${sub}_ses-01_dwi.nii.gz
    BVAL_FILE=$subdir/ses-01/dwi/${sub}_ses-01_dwi.bval
    BVEC_FILE=$subdir/ses-01/dwi/${sub}_ses-01_dwi.bvec
    T1W_FILE=$subdir/ses-01/anat/${sub}_ses-01_acq-mp2rage_T1w.nii.gz

    # ================================
	# Step #6: Extract b=0 from preprocessed DWI data
    # ================================
    step_start=$(date +%s)
    echo "Extracting b=0 image for registration with T1w"
    fslroi ${PREPROC_DIR}/${sub}_ses-01_dir-PA_dwi_aftereddy.nii.gz b0_1_PA_aftereddy.nii.gz 0 1
    step_end=$(date +%s)
    echo "Step #6 completed in $((step_end - step_start)) sec"
    echo
    # ================================
	# Step #7: Perform BET on T1w and b=0
    # ================================
    step_start=$(date +%s)
    echo "Running brain extraction on T1w and b0"
    bet $T1W_FILE T1w_brain -f 0.3 -m
    bet b0_1_PA_aftereddy.nii.gz b0_1_PA_aftereddy_brain -f 0.3 -m
    step_end=$(date +%s)
    echo "Step #7 completed in $((step_end - step_start)) sec"
    echo
     # ================================
	# Step #8: Perform registration from b=0 to T1w
     # ================================
    step_start=$(date +%s)
    echo "Aligning DWI data with T1-weighted image"
    epi_reg --epi=b0_1_PA_aftereddy_brain \
            --t1=$T1W_FILE \
            --t1brain=T1w_brain \
            --out=dwi2anatalign
    step_end=$(date +%s)
    echo "Step #8 completed in $((step_end - step_start)) sec"
    echo
    # ================================
	# Step #9: Convert transformation (T1w → DWI)
    # ================================
    step_start=$(date +%s)
    echo "Converting transformation matrix"
    convert_xfm -inverse -omat anat2dwialign.mat dwi2anatalign.mat
    step_end=$(date +%s)
    echo "Step #9 completed in $((step_end - step_start)) sec"
    echo
    # ================================
	# Step #10: Apply the transform (FSL → MRtrix)
    # ================================
    step_start=$(date +%s)
    echo "Transforming T1w to DWI space (MRtrix format)"
    transformconvert anat2dwialign.mat $T1W_FILE b0_1_PA_aftereddy_brain.nii.gz flirt_import anat2dwialign_mrtrix.txt
    mrtransform $T1W_FILE -linear anat2dwialign_mrtrix.txt -template b0_1_PA_aftereddy_brain.nii.gz T1w_in_dwi_space_highres.nii.gz -force
    step_end=$(date +%s)
    echo "Step #10 completed in $((step_end - step_start)) sec"
    echo
    # ================================
	# Step #11: Convert preprocessed DWI data to MRtrix format
    # ================================
    step_start=$(date +%s)
    echo "Converting preprocessed DWI data to MRtrix format"
    mrconvert ${PREPROC_DIR}/${sub}_ses-01_dir-PA_dwi_aftereddy.nii.gz \
        ${PREPROC_DIR}/${sub}_ses-01_dir-PA_dwi_aftereddy.mif \
        -fslgrad ${PREPROC_DIR}/${sub}_ses-01_dir-PA_dwi_aftereddy.eddy_rotated_bvecs \
                 $BVAL_FILE -force
    step_end=$(date +%s)
    echo "Step #11 completed in $((step_end - step_start)) sec"
    echo

    echo "Completed subject: $sub"

    break
done

