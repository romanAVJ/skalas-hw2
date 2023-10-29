# Use the official Ubuntu as the base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /hw

# Copy files from the host machine to the container
COPY src /hw/src
COPY ./Readme.md /hw/Readme.org

# Update the package lists and install extensions to ubuntu
RUN apt-get update && apt-get install -y nano vim unzip sed wget curl

# Clean up unnecessary files to reduce image size
RUN apt-get clean

# Set up the command to run when the container starts
CMD ["bash"]
