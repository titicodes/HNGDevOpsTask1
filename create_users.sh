#!/bin/bash

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %T") : $1" | tee -a /var/log/user_management.log
}

# Function to generate a random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Ensure the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <name-of-text-file>"
    exit 1
fi

input_file="$1"

# Ensure the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file not found"
    exit 1
fi

# Create the secure directory if it doesn't exist
mkdir -p /var/secure
chmod 700 /var/secure

# Clear previous logs
: > /var/log/user_management.log
: > /var/secure/user_passwords.csv

# Process each line in the input file
while IFS=';' read -r username groups; do
    # Trim whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Create a personal group for the user
    if ! getent group "$username" >/dev/null; then
        groupadd "$username"
        log_message "Group $username created"
    else
        log_message "Group $username already exists"
    fi

    # Create the user with the personal group
    if ! id "$username" >/dev/null 2>&1; then
        password=$(generate_password)
        useradd -m -g "$username" -s /bin/bash "$username"
        echo "$username:$password" | chpasswd
        log_message "User $username created with home directory and initial password set"

        # Add user to specified groups
        IFS=',' read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"; do
            group=$(echo "$group" | xargs)
            if ! getent group "$group" >/dev/null; then
                groupadd "$group"
                log_message "Group $group created"
            fi
            usermod -aG "$group" "$username"
            log_message "User $username added to group $group"
        done

        # Store the username and password securely
        echo "$username,$password" >> /var/secure/user_passwords.csv
    else
        log_message "User $username already exists"
    fi

done < "$input_file"

# Set permissions for the secure password file
chmod 600 /var/secure/user_passwords.csv

log_message "User creation process completed"
