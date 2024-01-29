#!/bin/bash

# Set the output directory
output_directory="image_data/$1"

# Set the frames per second (fps) equivalent to the lidar hz
fps=10

# Function to clean up and exit
cleanup_and_exit() {
    echo "Received SIGINT. Cleaning up and exiting..."
    exit 1
}

# Trap SIGINT and call cleanup_and_exit function
trap 'cleanup_and_exit' SIGINT

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Loop to capture images
while true; do
    # Generate a timestamp for the image filename
    timestamp=$(date +"%Y%m%d_%H%M%S")

    # Capture an image using fswebcam
    fswebcam -r 640x480 --no-banner "$output_directory/image_$timestamp.jpg"

    # Sleep for the specified duration to achieve the desired fps
    sleep "$(bc -l <<< "1/$fps")"
done