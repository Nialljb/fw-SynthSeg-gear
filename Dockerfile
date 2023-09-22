# Use the latest Python 3 docker image
FROM nialljb/njb-fw-freesurfer:base as base

ENV HOME=/root/
ENV FLYWHEEL="/flywheel/v0"
WORKDIR $FLYWHEEL
RUN mkdir -p $FLYWHEEL/input

# Installing the current project (most likely to change, above layer can be cached)
COPY ./ $FLYWHEEL/
COPY license.txt /usr/local/freesurfer/.license

# Dev dependencies (python, jq, flywheel installed in base)
# #software-properties-common=0.96.20.2-2 && yum install --no-install-recommends -y
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN yum update -y && \
    yum install -y unzip gzip wget && \
    yum clean all

RUN pip3 install jsonschema

# setup fs env
ENV PATH /usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV FREESURFER_HOME /usr/local/freesurfer
ENV FREESURFER /usr/local/freesurfer

# Configure entrypoint
RUN bash -c 'chmod +rx $FLYWHEEL/run.py' && \
    bash -c 'chmod +rx $FLYWHEEL/app/'
ENTRYPOINT ["python3","/flywheel/v0/main.sh"] 
# Flywheel reads the config command over this entrypoint