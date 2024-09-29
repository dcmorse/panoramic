# Use an official Node.js runtime as a parent image
FROM node:22.9.0-slim

# Set the working directory in the container
WORKDIR /app

# Install necessary tools and update CA certificates
RUN apt-get update && apt-get install -y ca-certificates git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PureScript and Spago
RUN npm install -g purescript spago

# Optionally install any additional packages you might need
# RUN npm install -g <other-packages>

# Copy the package.json and spago.dhall files to the container
COPY package.json spago.dhall packages.dhall ./

# Install npm dependencies
RUN npm install

# Install Spago dependencies
RUN spago install

# Copy your PureScript source code into the container
COPY . .

# Set the command to run when the container starts
CMD ["bash"]
