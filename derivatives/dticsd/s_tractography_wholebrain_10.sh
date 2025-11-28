# Whole-brain CSD-based probabilistic anatomically constrained tractography
tckgen WM_FOD_test.mif \
    -algorithm iFOD2 \
    -backtrack \
    -crop_at_gmwmi \
    -maxlength 250 \
    -step 0.8 \
    -select 500 \
    -nthreads 4 \
    CSD_Prob_ACT_500_test.tck


# tckgen WM_FOD_test.mif \
#     -algorithm iFOD2 \
#     -act 5TT_test.mif \
#     -backtrack \
#     -crop_at_gmwmi \
#     -seed_dynamic WM_FOD_test.mif \
#     -maxlength 250 \
#     -step 0.8 \
#     -select 300000 \
#     -nthreads 4 \
#     CSD_Prob_ACT_300000_test.tck



