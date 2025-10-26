# ====== 1. SLF I ======
tckedit CSD_Prob_ACT_300000_test.tck Left_SLFI_test.tck -include SFgL_test.mif -include PaL_test.mif -exclude MFgL_test.mif -exclude PrgL_test.mif -exclude MidSag_test.mif -exclude TeL_test.mif
tckedit CSD_Prob_ACT_300000_test.tck Right_SLFI_test.tck -include SFgR_test.mif -include PaR_test.mif -exclude MFgR_test.mif -exclude PrgR_test.mif -exclude MidSag_test.mif -exclude TeR_test.mif

# ====== 2. SLF II ======
tckedit CSD_Prob_ACT_300000_test.tck Left_SLFII_test.tck -include MFgL_test.mif -include PaL_test.mif -exclude SFgL_test.mif -exclude PrgL_test.mif -exclude MidSag_test.mif -exclude TeL_test.mif
tckedit CSD_Prob_ACT_300000_test.tck Right_SLFII_test.tck -include MFgR_test.mif -include PaR_test.mif -exclude SFgR_test.mif -exclude PrgR_test.mif -exclude MidSag_test.mif -exclude TeR_test.mif

# ====== 3. SLF III ======
tckedit CSD_Prob_ACT_300000_test.tck Left_SLFIII_test.tck -include PrgL_test.mif -include PaL_test.mif -exclude SFgL_test.mif -exclude MFgL_test.mif -exclude MidSag_test.mif -exclude TeL_test.mif
tckedit CSD_Prob_ACT_300000_test.tck Right_SLFIII_test.tck -include PrgR_test.mif -include PaR_test.mif -exclude SFgR_test.mif -exclude MFgR_test.mif -exclude MidSag_test.mif -exclude TeR_test.mif




