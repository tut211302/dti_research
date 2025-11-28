#!/bin/bash
# ================================
# Step #0: Set variables
# ================================
#SUBJECT_ID="sub-032301"
SUBJECT_ID="sub-032301"
SESSION_ID="ses-01"
PREPROC_DIR="/home/brain/dti_research/preproc"
DERIV_DIR="/home/brain/dti_research/derivatives/dticsd"
mkdir -p "${DERIV_DIR}/${SUBJECT_ID}"

cd "${DERIV_DIR}/${SUBJECT_ID}"

echo "======================================="
echo "Running 5TT generation for ${SUBJECT_ID}"
echo "======================================="

# ================================
# Step #1: Copy T1w in diffusion space
# ================================
echo "[Step 1/3] Copying T1-weighted image (in DWI space)..."
cp ${PREPROC_DIR}/${SUBJECT_ID}/T1w_in_dwi_space_highres.nii.gz .
#cp ${PREPROC_DIR}/test/T1w_in_dwi_space_highres.nii.gz .

# ================================
# Step #2: Generate 5TT image using FSL segmentation
# ================================
echo "[Step 2/3] Generating 5TT.mif using FSL-based segmentation..."
5ttgen fsl T1w_in_dwi_space_highres.nii.gz 5TT.mif -nocleanup -force
#5ttgen fsl /media/sf_share/MRI_MPILMBB_LEMON/MRI_Raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz 5TT.mif -nocleanup -force

# ================================
# Step #3: Convert for visualization
# ================================
echo "[Step 3/3] Converting 5TT.mif for visualization..."
5tt2vis 5TT.mif vis.mif -force

echo "======================================="
echo "5TT generation and visualization complete!"
echo "Output directory: ${DERIV_DIR}/${SUBJECT_ID}"
echo "======================================="
