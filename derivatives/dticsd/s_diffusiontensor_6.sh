# Step #1 Perform tensor fitting
dwi2tensor /home/brain/research/DATA/BIDS/preproc/test/sub-032301_ses-032301_dir-PA_dwi_aftereddy.mif dt_PA.mif -mask  /home/brain/research/DATA/BIDS/preproc/test/b0_1_PA_aftereddy_brain_mask.nii.gz

# Step #2 Compute diffusion tensor-based statistics
tensor2metric -fa FA_PA.mif -ad AD_PA.mif -rd RD_PA.mif -adc MD_PA.mif -vector PDD_PA.mif dt_PA.mif
