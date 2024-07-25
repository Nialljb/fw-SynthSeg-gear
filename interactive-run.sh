#!/usr/bin/env bash 

GEAR=fw-SynthSeg-gear
IMAGE=flywheel/synthseg:0.2.6
LOG=synthseg-0.2.6-66943d1fa63a4f83d2c4bf1e

# Command:
docker run -it --rm --entrypoint bash\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/app/:/flywheel/v0/app\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/utils:/flywheel/v0/utils\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/run.py:/flywheel/v0/run.py\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/${LOG}/input:/flywheel/v0/input\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/${LOG}/output:/flywheel/v0/output\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/${LOG}/work:/flywheel/v0/work\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/${LOG}/config.json:/flywheel/v0/config.json\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/${LOG}/manifest.json:/flywheel/v0/manifest.json\
	-v /Users/nbourke/GD/atom/unity/fw-gears/${GEAR}/fslinstaller.py:/flywheel/v0/fslinstaller.py\
	$IMAGE
