# Step #1: Extract b=0 images from b=0 data

# PA
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_1.nii.gz 0 1
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_2.nii.gz 1 1
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-PA_epi.nii.gz b0_PA_3.nii.gz 2 1

# AP
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_1.nii.gz 0 1
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_2.nii.gz 1 1
fslroi /home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/fmap/sub-032301_ses-01_acq-SEfmapDWI_dir-AP_epi.nii.gz b0_AP_3.nii.gz 2 1


# Step #2: Merge b=0 files into a single nifti file
fslmerge -t APPAb0_all.nii.gz \
    b0_AP_1.nii.gz b0_AP_2.nii.gz b0_AP_3.nii.gz \
    b0_PA_1.nii.gz b0_PA_2.nii.gz b0_PA_3.nii.gz


# Step #3: Run TOPUP
echo "running topup"
topup --imain=APPAb0_all.nii.gz \
      --datain=acquisition_parameters.txt \
      --config=b02b0download.cnf \
      --out=topup_PA_AP_b0 \
      --fout=field \
      --iout=unwarped_images


