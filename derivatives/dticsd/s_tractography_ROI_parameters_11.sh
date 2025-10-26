# Step: Change angle parameters (for test subject)
tckgen WM_FOD_test.mif -algorithm iFOD2 -mask WM_mask_test.mif -seed_image LV1_test.mif -angle 10 -maxlength 250 -select 500 -nthreads 4 CSD_Prob_500_leftV1_test_angle10.tck
tckgen WM_FOD_test.mif -algorithm iFOD2 -mask WM_mask_test.mif -seed_image LV1_test.mif -angle 20 -maxlength 250 -select 500 -nthreads 4 CSD_Prob_500_leftV1_test_angle20.tck
tckgen WM_FOD_test.mif -algorithm iFOD2 -mask WM_mask_test.mif -seed_image LV1_test.mif -angle 30 -maxlength 250 -select 500 -nthreads 4 CSD_Prob_500_leftV1_test_angle30.tck
tckgen WM_FOD_test.mif -algorithm iFOD2 -mask WM_mask_test.mif -seed_image LV1_test.mif -angle 40 -maxlength 250 -select 500 -nthreads 4 CSD_Prob_500_leftV1_test_angle40.tck



