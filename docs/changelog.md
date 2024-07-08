# Changelog

08/07/2024:
- clean up to make output more complient with BIDS

05/07/2024:
- Something changed on the Flywheel Toolkit side that broke fw.get so parent information cannot be retrieved from the file ID extracted in the config file. A workaround was implemented to extract the parent ID using the context object.

04/07/2024:
- surfa error resolved by running infant_synthsef with fspython instead of python
- parccelation and robust options not available for infant models
- increased number of threads to 8

03/07/2024:
- Added infant models to app which should be copied to FreeSurfer directory in Dockerfile with the aim of running by setting the `model` parameter to `infant`. Models are provided by the SynthSeg team trained on Hyperfine 3-18 month old data.

28/06/2024:
- CentOS 8 is EOL, updated to CentOS 9 (expected EOL 2027)
- Correction to output acquisition label

26/06/2024:
- demographics updated conditions for gathering sex/age to be more robust.
  - first checking dicom headers, then metadata
- Added acquisition label to the output

4/03/2024
- preallocate 'NA' do demographic data to avoid errors when no data is available


Updates to description & permissions 

30/06/2023:
Corrected bug in main script that prevented QC file from being generated. 