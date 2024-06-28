import os
import re

# Specify the directory you want to list files from
directory_path = '/flywheel/v0/input/input'
# List all files in the specified directory
for filename in os.listdir(directory_path):
    if os.path.isfile(os.path.join(directory_path, filename)):
        print(filename)
        # Remove anything after the '.' delimiter, including the delimiter itself
        filename_without_extension = filename.split('.')[0]

        no_white_spaces = filename_without_extension.replace(" ", "")
        cleaned_string = re.sub(r'[^a-zA-Z0-9]', '_', no_white_spaces)
        cleaned_string = cleaned_string.rstrip('_') # remove trailing underscore

print("cleaned_string: ", cleaned_string)
