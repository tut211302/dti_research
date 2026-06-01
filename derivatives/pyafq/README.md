Run pyAFQ for sub-032301

This folder contains a small wrapper and input checker to run `runAFQ.py` for subject sub-032301.

Files:

- `runAFQ.py` : main script (already in this folder).
- `run_pyafq_sub-032301.sh` : small wrapper to check inputs and run the script.
- `check_pyafq_inputs.py` : validates the expected input files exist.

Prerequisites:

- Python 3.8+ and a working pyAFQ installation. Typical extras: dipy, nibabel, numpy, scikit-image.
- If you have a virtual environment, activate it before running the wrapper.

Quick run:

1. Make the wrapper executable:

   chmod +x run_pyafq_sub-032301.sh

2. Activate your environment (example):

   source /path/to/venv/bin/activate

3. Run the wrapper:

   ./run_pyafq_sub-032301.sh

What the wrapper does:

- Validates the presence of DWI, bval, bvec, brain mask, and a tractography file used for import.
- Runs `runAFQ.py` which is configured to use paths within this repository.

Notes and next steps:

- If filenames or locations differ in your environment, edit `runAFQ.py` to point to the correct paths, or update `check_pyafq_inputs.py` accordingly.
- If you want to run multiple subjects, consider generalizing the scripts to accept a subject argument.
