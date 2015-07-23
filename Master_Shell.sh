#!/bin/bash
 
############################################################################
# Job Script to submit LPJ-GUESS simulations on the Hyalite cluster
# June 2015
# kristen.emmett@msu.montana.edu
############################################################################

cd /local/LPJGUESS_temp_KR
./guess Ins/$number.ins

