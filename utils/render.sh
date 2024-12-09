#!/bin/bash

# This script will render the structural and segmentation images in three planes (axial, coronal, sagittal) and combine them into a single image.
# The script uses FSL's slicer command to render the images.


# Source FSL
FSLDIR=/opt/conda
. $FSLDIR/etc/fslconf/fsl.sh
echo "FSLOUTPUTTYPE set to $FSLOUTPUTTYPE"

# Define paths to your images & pass in the subject, session, and acquisition labels
FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input/
OUTPUT_DIR=$FLYWHEEL_BASE/output
WORK_DIR=$FLYWHEEL_BASE/work
CONFIG_FILE=$FLYWHEEL_BASE/config.json
sub=$1
ses=$2
acq=$3
infant=$4

# Gather the structural and segmentation files
structural_file=`find $INPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`
seg_file=`find $OUTPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`

# Get segmentation in native space
/opt/conda/bin/flirt -in $seg_file -ref $structural_file -out $OUTPUT_DIR/${acq}_segmentation_native.nii.gz -applyxfm -usesqform
# sub-${sub}_ses-${ses}_acq-

# Render the images
/opt/conda/bin/slicer $structural_file $OUTPUT_DIR/segmentation_native.nii.gz -s 2 -x 0.4 ${WORK_DIR}/slice1.png -x 0.5 ${WORK_DIR}/slice2.png -x 0.6 ${WORK_DIR}/slice3.png -y 0.4 ${WORK_DIR}/slice4.png -y 0.5 ${WORK_DIR}/slice5.png -y 0.6 ${WORK_DIR}/slice6.png -z 0.4 ${WORK_DIR}/slice7.png -z 0.5 ${WORK_DIR}/slice8.png -z 0.6 ${WORK_DIR}/slice9.png
convert ${WORK_DIR}/slice7.png ${WORK_DIR}/slice8.png ${WORK_DIR}/slice9.png +append ${WORK_DIR}/axi.png
convert ${WORK_DIR}/slice4.png ${WORK_DIR}/slice5.png ${WORK_DIR}/slice6.png +append ${WORK_DIR}/cor.png
convert ${WORK_DIR}/slice1.png ${WORK_DIR}/slice2.png ${WORK_DIR}/slice3.png +append ${WORK_DIR}/sag.png

# Combine the images into a single image
convert ${WORK_DIR}/axi.png ${WORK_DIR}/cor.png ${WORK_DIR}/sag.png  -append ${OUTPUT_DIR}/${acq}_segmentation_QC.png
# sub-${sub}_ses-${ses}_acq-

# Clean up
# While here lets relabel the qc.csv file
mv ${OUTPUT_DIR}/qc.csv ${OUTPUT_DIR}/${acq}_${infant}qc.csv
# sub-${sub}_ses-${ses}_acq-

# If there is a file containing 'synthseg_volumes.csv', then remove vol.csv
# sub-${sub}_ses-${ses}_acq-
if [ -f ${OUTPUT_DIR}/${acq}_synthseg_volumes.csv ]; then
    rm ${OUTPUT_DIR}/vol.csv
fi






# ------------------------------------------------------ #
# Render images using FSLeyes
# ------------------------------------------------------ #
# Difficult to render images in a headless environment
# It did work in one iteration...

# # Define paths to your images
# INPUT_DIR=$FLYWHEEL_BASE/input/
# structuralImage=`find $INPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`

# OUTPUT_DIR=$FLYWHEEL_BASE/output
# segmentationImage=`find $OUTPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`

# # Step 1: Adjust the structural image (optional intensity normalization)
# fslmaths $structuralImage -thr 0 -uthr 11 adjustedStructural.nii.gz

# # Step 2: Create a binary mask of the segmentation (adjusting thresholds)
# fslmaths $segmentationImage -bin binarySegmentation.nii.gz
# # -thr 0.5

# # Step 3: Apply a color map to the segmentation
# # This step is a bit more complex as FSL doesn't directly apply color maps via the command line.
# # You may need to use an external tool or custom script to apply color maps.

# # Step 4: Overlay the segmentation onto the structural image
# # Using fsleyes render to create the overlay image
# fsleyes render -of /flywheel/v0/output/QC-overlay.png --scene ortho --worldLoc \-100 \-100 \-100 --displaySpace world --size 800 600 $structuralImage -cm gray -dr 0 10 $segmentationImage -cm cortical -dr 1 200 -a 60

# # Note: Adjust the --colourMap, --displayRange, and other parameters as needed.
