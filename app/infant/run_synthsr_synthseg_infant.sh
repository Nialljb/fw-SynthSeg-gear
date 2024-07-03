#!/bin/zsh
# bash also works, testing on Mac

# Note: I've not really tested synthsr -> synthseg infant that much but

# source freesurfer
export FREESURFER_HOME=/Applications/freesurfer/dev/
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# point to folder with mri_synthseg_infant make sure transferDir/models/* have been copied to $FREESURFER_HOME/models/
# before running the code
transferDir=/Users/henrytregidgo/Documents/testVolumes/transfer2Niall

# working dir and num threads
working_directory=/Users/henrytregidgo/Documents/testVolumes
nthreads=8

# specify file paths
in_file=$working_directory/D2_25003_01_ZFB_month_36_T1.nii.gz
mid_file=$working_directory/D2_25003_01_ZFB_month_36_T1_synthsr.nii.gz
out_seg=$working_directory/D2_25003_01_ZFB_month_36_T1_sr_synthseg_infant.nii.gz
out_vols=$working_directory/D2_25003_01_ZFB_month_36_T1_sr_synthseg_infant_vols.csv
out_qc=$working_directory/D2_25003_01_ZFB_month_36_T1_sr_synthseg_infant_QC.csv

# if this line fails because of the lowfield flag you need a later version of freesurfer
mri_synthsr --i $in_file --o $mid_file --lowfield --threads $nthreads

fspython $transferDir/mri_synthseg_infant --i $mid_file --o $out_seg --vol $out_vols --qc $out_qc --threads $nthreads


