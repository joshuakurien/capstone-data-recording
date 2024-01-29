#!/bin/bash

background_pids=()

# Function to clean up and exit
cleanup_and_exit() {
    echo "Received SIGINT. Cleaning up and exiting..."

    # Loop through background PIDs and terminate each process
    for pid in "${background_pids[@]}"; do
        echo "Terminating background process with PID $pid..."
        kill -SIGTERM "$pid"
        wait "$pid"  # Wait for the background process to exit
    done

    exit 1
}

# Trap SIGINT and call cleanup_and_exit function
trap 'cleanup_and_exit' SIGINT

# Run lidar data collection node in background and capture pid
ros2 launch capstone_sw sllidar_a1_launch.py &
background_pids+=("$!")

# Date used as a UID in some way
current_date=$(date '+%Y%m%d%H%M%S')

# Run ros2 bag to store published lidar data in background and capture pid
ros2 bag record -o "lidar_data/$current_date" /raw_lidar &
background_pids+=("$!")

# Run script to store images in background and capture pid
/home/joshua/ros2_ws/src/capstone-data-recording/image_collection.sh "$current_date" &
background_pids+=("$!")

# Wait for all background processes to finish or be interrupted
wait "${background_pids[@]}"

# Cleanup and exit after the background process completes
cleanup_and_exit
