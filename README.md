# User Creation Script

This repository contains a Bash script to automate the creation of Linux users, assign them to groups, set up home directories, generate random passwords, and log all actions. The generated passwords are stored securely.

## Files in this Repository

- `create_users.sh`: The main Bash script that performs user creation and management.
- `README.md`: This file, providing an overview and instructions for the script.

## Script Overview

The `create_users.sh` script reads a text file containing usernames and group names, where each line is formatted as `user;groups`. It creates users and groups, sets up home directories, generates random passwords, logs actions to `/var/log/user_management.log`, and stores passwords securely in `/var/secure/user_passwords.csv`.

**Example Input File (users.txt):**

