#!/usr/bin/env python
import sys
import os

# Add top-level package directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Verify sys.path
print("sys.path:", sys.path)

import logging

# import flywheel functions
from flywheel_gear_toolkit import GearToolkitContext
from app.parser import parse_config
from app.command_line import exec_command
from utils.gatherDemographics import get_demo

# The gear is split up into 2 main components. The run.py file which is executed
# when the container runs. The run.py file then imports the rest of the gear as a
# module.

log = logging.getLogger(__name__)
def main(context: GearToolkitContext) -> None:
    """Parses config and runs."""
    gear_inputs, gear_options, app_options = parse_config(context)
    
    # Execute the main command
    command = "/flywheel/v0/app/main.sh"
    os.system(command)

    # Add demographic data to the output
    print("concatenating demographics...")
    get_demo(context)

    # # Generate a QC image
    # qc_command = "/flywheel/v0/utils/render.sh"
    # os.system(qc_command)
    # NOTE: running from from demo instead to pass in the context

# Only execute if file is run as main, not when imported by another module
if __name__ == "__main__":  # pragma: no cover
    # Get access to gear config, inputs, and sdk client if enabled.
    with GearToolkitContext() as gear_context:

        # Initialize logging, set logging level based on `debug` configuration
        # key in gear config.
        gear_context.init_logging()

        # Pass the gear context into main function defined above.
        main(gear_context)