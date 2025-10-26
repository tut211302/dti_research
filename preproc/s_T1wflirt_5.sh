#!/bin/bash
# cd /home/brain/research/DATA/BIDS/preproc/

# ================================
# Step #1: Extract b=0 from preprocessed DWI data
# ================================
echo "Extracting b=0 image for registration with T1w"
fslroi sub-032301_ses-01_dir-PA_dwi_aftereddy.nii.gz b0_1_PA_aftereddy.nii.gz 0 1


# ================================
# Step #2: Perform BET on T1w and b=0
# ================================
echo "Running brain extraction on T1w and b0"
bet /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz \
    T1w_brain -f 0.3 -m
bet b0_1_PA_aftereddy.nii.gz b0_1_PA_aftereddy_brain -f 0.3 -m


# ================================
# Step #3: Perform registration from b=0 to T1w
# ================================
echo "Aligning dwi data with T1-weighted image"
epi_reg --epi=b0_1_PA_aftereddy_brain \
        --t1=/home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz \
        --t1brain=T1w_brain \
        --out=dwi2anatalign


# ================================
# Step #4: Convert transformation (T1w → DWI)
# ================================
echo "Convert transformation matrix"
convert_xfm -inverse -omat anat2dwialign.mat dwi2anatalign.mat


# ================================
# Step #5: Apply the transform (FSL → MRtrix)
# ================================
echo "Perform T1w to b=0 registration (convert to MRtrix format)"
transformconvert anat2dwialign.mat \
    /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz \
    b0_1_PA_aftereddy_brain.nii.gz flirt_import anat2dwialign_mrtrix.txt -force

mrtransform /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz \
    -linear anat2dwialign_mrtrix.txt \
    -template b0_1_PA_aftereddy_brain.nii.gz \
    T1w_in_dwi_space_highres.nii.gz -force


# ================================
# Step #6: Convert preprocessed DWI data to MRtrix format
# ================================
echo "Convert preprocessed dMRI data from FSL to MRtrix format"
mrconvert sub-032301_ses-01_dir-PA_dwi_aftereddy.nii.gz \
    sub-032301_ses-01_dir-PA_dwi_aftereddy.mif \
    -fslgrad sub-032301_ses-01_dir-PA_dwi_aftereddy.eddy_rotated_bvecs \
             /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/dwi/sub-032301_ses-01_dwi.bval

echo "Registration and conversion completed successfully!"
