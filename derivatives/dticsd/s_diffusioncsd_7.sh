# ================================
# Step #1: Estimate response function (dhollander method)
# ================================
dwi2response dhollander \
  /home/brain/dti_research/preproc/test/sub-032301_ses-01_dir-PA_dwi_aftereddy.mif \
  RF_WM_PA.txt RF_GM_PA.txt RF_CSF_PA.txt \
  -mask /home/brain/dti_research/preproc/test/b0_1_PA_aftereddy_brain_mask.nii.gz \
  -voxels RF_voxels_PA.mif


# ================================
# Step #2: Estimate fiber orientation distribution (MSMT-CSD)
# ================================
dwi2fod msmt_csd \
  /home/brain/dti_research/preproc/test/sub-032301_ses-01_dir-PA_dwi_aftereddy.mif \
  RF_WM_PA.txt WM_FOD_PA.mif \
  RF_GM_PA.txt GM_FOD_PA.mif \
  RF_CSF_PA.txt CSF_FOD_PA.mif \
  -mask /home/brain/dti_research/preproc/test/b0_1_PA_aftereddy_brain_mask.nii.gz
