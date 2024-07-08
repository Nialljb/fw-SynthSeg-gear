import flywheel
import json
import pandas as pd
from datetime import datetime
import re
import logging
import os
import subprocess

# Setup basic logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

#  Module to identify the correct template use for the subject VBM analysis based on age at scan
#  Need to get subject identifiers from inside running container in order to find the correct template from the SDK

def get_demo(context):


    input_container = context.client.get_analysis(context.destination["id"])
    
    
    
    proj_id = input_container.parents["project"]
    project_container = context.client.get(proj_id)
    project_label = project_container.label
    print("project label: ", project_label)

    # Get the subject id from the session id
    # & extract the subject container
    subject_id = input_container.parents['subject']
    subject_container = context.client.get(subject_id)
    subject = subject_container.reload()
    print("subject label: ", subject.label)
    subject_label = subject.label

    # Get the session id from the input file id
    # & extract the session container
    session_id = input_container.parents['session']
    session_container = context.client.get(session_id)
    session = session_container.reload()
    session_label = session.label
    print("session label: ", session.label)

    data = []
    cleaned_string = 'NA'

    # Read config.json file
    p = open('/flywheel/v0/config.json')
    config = json.loads(p.read())

    # Read API key in config file
    api_key = (config['inputs']['api-key']['key'])
    fw = flywheel.Client(api_key=api_key)
    # gear = 'synthseg'
    

    # NOTE: This is the old way of getting the session and subject labels. This has stopped working for some reason.

    # # Get the input file id
    # input_file_id = (config['inputs']['input']['hierarchy']['id'])
    # print("input_file_id is : ", input_file_id)
    # input_container = fw.get(input_file_id)

    # # Get the session id from the input file id
    # # & extract the session container
    # session_id = input_container.parents['session']
    # session_container = fw.get(session_id)
    # session = session_container.reload()
    # session_label = session.label
    # print("session label: ", session.label)

    # # Get the subject id from the session id
    # # & extract the subject container
    # subject_id = session_container.parents['subject']
    # subject_container = fw.get(subject_id)
    # subject = subject_container.reload()
    # print("subject label: ", session.subject.label)
    # subject_label = session.subject.label


    # Specify the directory you want to list files from
    directory_path = '/flywheel/v0/input/input'
    # List all files in the specified directory
    for filename in os.listdir(directory_path):
        if os.path.isfile(os.path.join(directory_path, filename)):
            filename_without_extension = filename.split('.')[0]
            no_white_spaces = filename_without_extension.replace(" ", "")
            # no_white_spaces = filename.replace(" ", "")
            cleaned_string = re.sub(r'[^a-zA-Z0-9]', '_', no_white_spaces)
            cleaned_string = cleaned_string.rstrip('_') # remove trailing underscore

    print("cleaned_string: ", cleaned_string)

    # -------------------  Get the subject age & matching template  -------------------  #

    # get the T2w axi dicom acquisition from the session
    # Should contain the DOB in the dicom header
    # Some projects may have DOB removed, but may have age at scan in the subject container
    age = 'NA'
    PatientSex = 'NA'
    for acq in session_container.acquisitions.iter():
        # print(acq.label)
        acq = acq.reload()

        if 'T2' in acq.label and 'AXI' in acq.label and 'Segmentation' not in acq.label: 
            # pull out the acquisition label and clean
            # no_white_spaces = acq.label.replace(" ", "")
            # cleaned_string = re.sub(r'[^a-zA-Z0-9]', '_', no_white_spaces)
            # cleaned_string = cleaned_string.rstrip('_') # remove trailing underscore

            for file_obj in acq.files: # get the files in the acquisition
                # Screen file object information & download the desired file
                if file_obj['type'] == 'dicom':
                    
                    dicom_header = fw._fw.get_acquisition_file_info(acq.id, file_obj.name)
                    SeriesDate = dicom_header.info["SeriesDate"]

                    try:
                        print("searching for sex in dicom header..")
                        PatientSex = dicom_header.info.get("PatientSex", None)
                        if PatientSex is None:
                            print("Not found in dicom header: searching subject metadata..")
                            PatientSex = subject.sex
                        else:
                            PatientSex = "NA"
                    except Exception as e:
                        PatientSex = "NA"
                        logging.error("Error encountered: ", exc_info=True)

                        continue

                    try:
                        logging.debug("Before processing the variable at line 57")

                        print("searching for DOB in dicom header..")
                        PatientBirthDate = dicom_header.info.get("PatientBirthDate", None)
                        if PatientBirthDate is None: # If not found in the primary source
                            print("Not found in dicom header: searching for DOB in subject metadata..")
                            datetime_obj = subject.date_of_birth
                            # Parse the string into a datetime object
                            PatientBirthDate = datetime_obj.strftime('%Y%m%d')
                            print(PatientBirthDate)

                        if PatientBirthDate is None:
                            print("Not found in subject metadata: searching for DOB in session metadata..")
                            age = int(session.age / 365 / 24 / 60 / 60) # This is in seconds
                        if PatientBirthDate is not None:
                            age = (datetime.strptime(SeriesDate, '%Y%m%d')) - (datetime.strptime(PatientBirthDate, '%Y%m%d'))
                            age = age.days
                        else:  # If not found in any source
                            age = "NA"
                            logging.debug("After processing the variable at line 57")

                    except Exception as e:
                        age = "NA"
                        logging.error("Error encountered: ", exc_info=True)

                        continue
    
    # assign values to lists. 
    data = [{'subject': subject_label, 'session': session_label, 'age': age, 'sex': PatientSex, 'acquisition': cleaned_string}]  
    # Creates DataFrame.  
    demo = pd.DataFrame(data)

    filePath = '/flywheel/v0/output/vol.csv'
    with open(filePath) as csv_file:
        vols = pd.read_csv(csv_file, index_col=None, header=0) 
        vols = vols.drop('subject', axis=1)

    frames = [demo, vols]
    df = pd.concat(frames, axis=1)

    out_name = f"sub-{subject_label}_ses-{session_label}_acq-{cleaned_string}_synthseg_volumes.csv"
    outdir = ('/flywheel/v0/output/' + out_name)
    df.to_csv(outdir)

    # Run the render script to generate the QC image 

    # Construct the command to run your bash script with variables as arguments
    qc_command = f"/flywheel/v0/utils/render.sh '{subject_label}' '{session_label}' '{cleaned_string}'"

    # Execute the bash script
    subprocess.run(qc_command, shell=True)

    print("Demographics: ", subject_label, session_label, age, PatientSex)
    return subject_label, session_label, age, PatientSex