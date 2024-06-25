#!/bin/bash


OUTPUT_DIR="/opt/sentinela"
OUTPUT_FILE="${OUTPUT_DIR}/sentinela/data.json"

# Create the output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Create the output file if it doesn't exist
if [ ! -f "$OUTPUT_FILE" ]; then
    touch "$OUTPUT_FILE"
fi

# Function to check if jq is installed
check_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing jq..."
        install_jq
    else
        echo "jq is already installed."
    fi
}

# Function to install jq based on the OS
install_jq() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y jq
                ;;
            centos|rhel|fedora)
                sudo yum install -y epel-release
                sudo yum install -y jq
                ;;
            arch)
                sudo pacman -Sy jq
                ;;
            *)
                echo "Unsupported OS. Please install jq manually."
                exit 1
                ;;
        esac
    else
        echo "Cannot determine the OS. Please install jq manually."
        exit 1
    fi
}

# Function to collect services and convert to JSON
collect_services() {
    # Get the output from systemctl command
    services=$(systemctl list-units --type=service --all --plain)

    # Initialize JSON array
    json="["

    # Read each line of the services output
    while IFS= read -r line; do
        # Skip the header and empty lines
        if [[ "$line" == *"LOAD"* ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Parse the line into service name, load status, active status, and sub status
        service_name=$(echo "$line" | awk '{print $1}')
        load_status=$(echo "$line" | awk '{print $2}')
        active_status=$(echo "$line" | awk '{print $3}')
        sub_status=$(echo "$line" | awk '{print $4}')
        description=$(echo "$line" | awk '{print $5" "$6" "$7" "$8" "$9" "$10" "$11}')

        # Add the service information to the JSON array
        json+=$(jq -n \
            --arg service "$service_name" \
            --arg load "$load_status" \
            --arg active "$active_status" \
            --arg sub "$sub_status" \
            --arg desc "$description" \
            '{service: $service, load: $load, active: $active, sub: $sub, description: $desc}'),
    done <<< "$services"

    # Remove the trailing comma
    json=${json%,}

    # Close the JSON array
    json+="]"

    # Output the JSON
    echo "$json"
}

# Main script execution
check_jq_installed
collect_services > $OUTPUT_FILE
echo "Services successfully pushed to $OUTPUT_FILE"