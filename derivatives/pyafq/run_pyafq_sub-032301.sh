#!/usr/bin/env bash
set -euo pipefail

# Wrapper to run runAFQ.py for sub-032301
# Usage: ./run_pyafq_sub-032301.sh

BASE=/home/brain/dti_research
PYAFQ_DIR=$BASE/derivatives/pyafq
RUN_SCRIPT=$PYAFQ_DIR/runAFQ.py

echo "Checking required files and environment..."
python3 $PYAFQ_DIR/check_pyafq_inputs.py

echo "Activating virtualenv (if any). If you use a venv, activate it now or modify this script."
# Example: source $BASE/.venv/bin/activate

echo "Running pyAFQ script..."
python3 -u $RUN_SCRIPT

echo "Done. Check $PYAFQ_DIR/sub-032301 for outputs."
