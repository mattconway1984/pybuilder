# Use an official Python runtime as a parent image - Debian stretch
FROM python:3.6-slim

# Set the working directory to /workspace - bind mounted to current dir
WORKDIR /workspace

# Install general stuff
RUN apt-get update
RUN apt install -y make patch git gcc zip curl

# Install any needed python packages
RUN pip install --upgrade pip
RUN pip install pytest wheel pylint twine
RUN pip install sphinx sphinx_rtd_theme
