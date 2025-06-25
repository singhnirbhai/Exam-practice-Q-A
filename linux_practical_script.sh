
#!/bin/bash

# This script is designed to grade a set of Linux commands.
# It prepares a controlled environment for each question,
# then checks if the expected outcome from the student's command is achieved.
#
# It must be run as the root user.
#
# Usage: sudo ./grade_linux_exam.sh

# --- Configuration ---
TEMP_DIR="/tmp/linux_exam_check_temp" # Directory for temporary files and directories
LOG_FILE="${TEMP_DIR}/check_log.txt"  # Location of the log file

CORRECT_ANSWERS=0
INCORRECT_ANSWERS=0
TOTAL_QUESTIONS=38 # Total number of questions

# Questions that the script cannot automatically verify
# (because they involve displaying output to the screen)
UNCHECKABLE_QUESTIONS=(15 16 36)

# --- Helper Functions ---

# Function to log messages to the log file and console
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check each command and update the score
check_command() {
    local q_num="$1"        # Question number
    local description="$2"  # Description of the question
    local check_cmd="$3"    # Command or condition to check
    local cleanup_cmd="$4"  # Optional, cleanup command for this specific check

    log "--- Checking Q$q_num: $description ---"

    # Question-specific initial setup
    # These commands ensure a state that exists before the student's command would be run.
    case $q_num in
        3) useradd -m john &>/dev/null ;; # Create 'john' user
        4) useradd -m alice &>/dev/null; groupadd devops &>/dev/null; touch /root/report.txt &>/dev/null ;;
        5) touch /root/secret.txt &>/dev/null ;;
        6) touch /root/superfile.sh &>/dev/null ;;
        7) useradd -m david &>/dev/null; touch /root/project.txt &>/dev/null ;;
        11) groupadd ops_team &>/dev/null ;;
        12) groupadd ops_team &>/dev/null; useradd -m analyst &>/dev/null ;;
        13|14) echo "test data for links" > /root/data.txt &>/dev/null ;;
        17) useradd -m student &>/dev/null; mkdir -p /home/student &>/dev/null ;; # Create /home/student
        18) mkdir -p /opt/reports &>/dev/null; echo "notes content" > /var/tmp/devops_notes.txt &>/dev/null ;;
        19) # Ensure file exists if Q18 wasn't run
            mkdir -p /opt/reports &>/dev/null; echo "notes content" > /opt/reports/devops_notes.txt &>/dev/null
            ;;
        20) useradd -m manager &>/dev/null; groupadd qa_team &>/dev/null; mkdir -p /opt/reports &>/dev/null ;;
        21) mkdir -p /usr/local/bin &>/dev/null; touch /usr/local/bin/startup.sh &>/dev/null; chmod 644 /usr/local/bin/startup.sh &>/dev/null ;; # Base permission
        22) useradd -m sam &>/dev/null; mkdir -p /usr/local/bin &>/dev/null; touch /usr/local/bin/startup.sh &>/dev/null ;;
        24) groupadd auditlog &>/dev/null ;;
        25) groupadd auditlog &>/dev/null; groupadd qa_team &>/dev/null ;;
        26) touch /var/log/syslog &>/dev/null ;; # Create dummy syslog file
        29) useradd -m intern &>/dev/null; usermod -s /bin/sh intern &>/dev/null ;; # Create 'intern' with a default shell
        30) useradd -m testuser &>/dev/null; echo "testuser:password" | chpasswd &>/dev/null ;; # Create 'testuser' with a password
        31) useradd -m testuser &>/dev/null; echo "testuser:password" | chpasswd &>/dev/null; usermod -L testuser &>/dev/null ;; # Create and lock 'testuser'
        32) useradd -m oldstaff &>/dev/null; mkdir -p /home/oldstaff &>/dev/null ;; # Create 'oldstaff' with a home directory
        33) useradd -m deploy &>/dev/null ;;
        34) useradd -m developer &>/dev/null; groupadd engineering &>/dev/null ;;
        35) useradd -m auditor &>/dev/null; groupadd compliance &>/dev/null; groupadd security &>/dev/null ;;
        37) groupadd sysadmin &>/dev/null; useradd -m ryan &>/dev/null; useradd -m sarah &>/dev/null; useradd -m harry &>/dev/null; usermod -s /bin/bash harry &>/dev/null ;; # Give 'harry' an interactive shell initially, so it can be changed to nologin later
        38) groupadd sysadmin &>/dev/null; mkdir -p /common/admin &>/dev/null; chown root:root /common/admin &>/dev/null; chmod 755 /common/admin &>/dev/null ;; # Initial state for /common/admin
    esac

    # Execute the check command and update the score based on the result
    if eval "$check_cmd"; then
        log "Q$q_num: Correct - $description"
        ((CORRECT_ANSWERS++))
    else
        log "Q$q_num: Incorrect - $description"
        ((INCORRECT_ANSWERS++))
    fi

    # Question-specific cleanup
    # Revert temporary changes to ensure each question starts with a clean slate.
    case $q_num in
        1) rm -f /tmp/passwd.bak &>/dev/null; rm -f /root/backups/passwd.bak &>/dev/null ;;
        2) rm -f /tmp/passwd.bak &>/dev/null; rm -f /root/backups/passwd.bak &>/dev/null ;;
        3) userdel -r john &>/dev/null ;;
        4) rm -f /root/report.txt &>/dev/null; userdel -r alice &>/dev/null; groupdel devops &>/dev/null ;;
        5) rm -f /root/secret.txt &>/dev/null ;;
        6) rm -f /root/superfile.sh &>/dev/null ;;
        7) rm -f /root/project.txt &>/dev/null; userdel -r david &>/dev/null ;;
        8) rm -f /tmp/umask_test_file &>/dev/null ;;
        9) userdel -r devadmin &>/dev/null ;;
        10) groupdel ops_team &>/dev/null ;;
        11) userdel -r deploy &>/dev/null; groupdel ops_team &>/dev/null ;;
        12) userdel -r analyst &>/dev/null; groupdel ops_team &>/dev/null ;;
        13|14) rm -f /root/data.txt /root/data_hardlink.txt /root/data_softlink.txt &>/dev/null ;;
        17) rm -f /home/student/devops_notes.txt /var/tmp/devops_notes.txt &>/dev/null; userdel -r student &>/dev/null ;;
        18) rm -f /var/tmp/devops_notes.txt /opt/reports/devops_notes.txt &>/dev/null; rmdir /opt/reports &>/dev/null ;;
        19) rm -f /opt/reports/devops_notes.txt &>/dev/null; rmdir /opt/reports &>/dev/null ;;
        20) rmdir /opt/reports &>/dev/null; userdel -r manager &>/dev/null; groupdel qa_team &>/dev/null ;;
        21) rm -f /usr/local/bin/startup.sh &>/dev/null; rmdir /usr/local/bin &>/dev/null ;;
        22) rm -f /usr/local/bin/startup.sh &>/dev/null; rmdir /usr/local/bin &>/dev/null; userdel -r sam &>/dev/null ;;
        23) rm -rf /tmp/secure_folder_test &>/dev/null ;;
        24) userdel -r loguser &>/dev/null; groupdel auditlog &>/dev/null ;;
        25) userdel -r support &>/dev/null; groupdel auditlog &>/dev/null; groupdel qa_team &>/dev/null ;;
        26) rm -f /var/log/syslog /tmp/syslog_link /tmp/syslog_hard &>/dev/null ;;
        27) userdel trainer &>/dev/null ;; # Do not use -r as no home directory was created
        28) userdel -r intern &>/dev/null ;;
        29) userdel -r intern &>/dev/null ;;
        30) userdel -r testuser &>/dev/null ;;
        31) userdel -r testuser &>/dev/null ;;
        32) userdel -r oldstaff &>/dev/null ;;
        33) userdel -r deploy &>/dev/null; groupdel docker_users &>/dev/null ;;
        34) userdel -r developer &>/dev/null; groupdel engineering &>/dev/null ;;
        35) userdel -r auditor &>/dev/null; groupdel compliance &>/dev/null; groupdel security &>/dev/null ;;
        37) userdel -r ryan &>/dev/null; userdel -r sarah &>/dev/null; userdel -r harry &>/dev/null; groupdel sysadmin &>/dev/null ;;
        38) rm -rf /common/admin &>/dev/null; groupdel sysadmin &>/dev/null ;;
    esac

    # If an optional cleanup command is provided, run it
    if [ -n "$cleanup_cmd" ]; then
        eval "$cleanup_cmd" &>/dev/null
    fi

    log "--- Q$q_num finished ---"
}

# --- Main Script Logic ---

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Initial setup: Create temporary directories and clear the log file
mkdir -p "$TEMP_DIR" /root/backups /opt/reports /common/admin /usr/local/bin &>/dev/null
