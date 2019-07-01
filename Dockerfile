# Use an official Python runtime as a parent image - Debian stretch
FROM python:3.6-slim

# Set the working directory to /workspace - bind mounted to current dir
WORKDIR /workspace

# Install general stuff
RUN apt-get update
RUN apt install -y make patch git smbclient gcc zip curl

# Install any needed python packages
RUN pip install --upgrade pip
RUN pip install pytest wheel pylint
RUN pip install twine
RUN pip install sphinx sphinx_rtd_theme

# libs for running pyqt...
RUN apt install -y libglib2.0-0 libxcb1 libxcb1-dev libgl1-mesa-glx  libxrender1 libxkbcommon-x11-0 libfontconfig1 libxrender1
# note that if libraries are missing, you can get additional debug by exporting QT_DEBUG_PLUGINS=1
# libs for running windowless application...
RUN apt install -y xvfb
