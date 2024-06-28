# Changelog

28/06/2024:
- CentOS 8 is EOL, updated to CentOS 9 (expected EOL 2027)
- Correction to output acquisition label
s
26/06/2024:
- demographics updated conditions for gathering sex/age to be more robust.
  - first checking dicom headers, then metadata
- Added acquisition label to the output

4/03/2024
- preallocate 'NA' do demographic data to avoid errors when no data is available


Updates to description & permissions 

30/06/2023:
Corrected bug in main script that prevented QC file from being generated. 