#!/bin/bash
# ================================
# Set variables
# ================================
SUBJECT_ID="sub-032301"
SESSION_ID="ses-01"
PREPROC_DIR="/home/brain/dti_research/preproc/${SUBJECT_ID}"
DERIV_DIR="/home/brain/dti_research/derivatives/tractography/${SUBJECT_ID}"
mkdir -p "${DERIV_DIR}"
cd "${DERIV_DIR}"

echo "======================================="
echo "Running tractography for ${SUBJECT_ID}"
echo "======================================="

# ================================
# Step #1: Create white matter mask from 5TT.mif
# ================================
#echo "[Step 1/5] Creating white matter mask..."
#mrconvert -coord 3 2 /home/brain/dti_research/derivatives/dticsd/${SUBJECT_ID}/5TT.mif WM_mask.mif -force

# ================================
# Step #2: DTI deterministic tractography
# ================================
echo "[Step 2/5] Running DTI deterministic tractography..."
tckgen ${PREPROC_DIR}/sub-032301_ses-01_dir-PA_dwi_aftereddy.mif \
    -algorithm iFOD2 \
    -seed_dynamic /home/brain/dti_research/derivatives/dticsd/WM_FOD_PA.mif \
    -maxlength 250 \
    -select 300000 \
    -nthreads 4 \
    Tensor_Det_300000.tck -force
# echo "[Step 2/5] Running DTI deterministic tractography..."
# tckgen ${PREPROC_DIR}/${SUBJECT_ID}_ses-01_dir-PA_dwi_aftereddy.mif \
#     -algorithm Tensor_Det \
#     -mask WM_mask.mif \
#     -seed_image LV1.mif \
#     -maxlength 250 \
#     -select 500 \
#     -nthreads 4 \
#     Tensor_Det_500_leftV1.tck -force

# ================================
# Step #3: DTI probabilistic tractography
# ================================
# echo "[Step 3/5] Running DTI probabilistic tractography..."
# tckgen ${PREPROC_DIR}/${SUBJECT_ID}_ses-01_dir-PA_dwi_aftereddy.mif \
#     -algorithm Tensor_Prob \
#     -mask WM_mask.mif \
#     -seed_image LV1.mif \
#     -maxlength 250 \
#     -select 500 \
#     -nthreads 4 \
#     Tensor_Prob_500_leftV1.tck -force

# # ================================
# # Step #4: CSD deterministic tractography
# # ================================
# echo "[Step 4/5] Running CSD deterministic tractography..."
# tckgen ../../dticsd/${SUBJECT_ID}/WM_FOD_PA.mif \
#     -algorithm SD_STREAM \
#     -seed_image LV1.mif \
#     -mask WM_mask.mif \
#     -maxlength 250 \
#     -select 500 \
#     -nthreads 4 \
#     CSD_Det_500_leftV1.tck -force

# # ================================
# # Step #5: CSD probabilistic tractography
# # ================================
# echo "[Step 5/5] Running CSD probabilistic tractography..."
# tckgen ../../dticsd/${SUBJECT_ID}/WM_FOD_PA.mif \
#     -algorithm iFOD2 \
#     -seed_image LV1.mif \
#     -mask WM_mask.mif \
#     -maxlength 250 \
#     -select 500 \
#     -nthreads 4 \
#     CSD_Prob_500_leftV1.tck -force

echo "======================================="
echo "Tractography for ${SUBJECT_ID} completed successfully!"
echo "Output directory: ${DERIV_DIR}"
echo "======================================="

