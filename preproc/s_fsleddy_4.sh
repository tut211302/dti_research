

echo "performing FSL BET on PA b=0 image"
# Step #1 performing BET on b=0 image
bet b0_PA_1 b0_PA1_brain -m -f 0.2

echo "running EDDY on PA data" 
# Step #2 running EDDY on PA data
eddy_cpu \
  --imain=/home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/dwi/sub-032301_ses-01_dwi.nii.gz \
  --mask=b0_PA1_brain_mask.nii.gz \
  --index=/home/brain/research/DATA/BIDS/preproc/index_PA.txt \
  --acqp=/home/brain/research/DATA/BIDS/preproc/acquisition_parameters.txt \
  --bvecs=/home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/dwi/sub-032301_ses-01_dwi.bvec \
  --bvals=/home/brain/research/DATA/BIDS/raw/sub-032301/ses-01/dwi/sub-032301_ses-01_dwi.bval \
  --fwhm=0 \
  --topup=topup_PA_AP_b0 \
  --flm=quadratic \
  --out=sub-032301_ses-01_dir-PA_dwi_aftereddy



