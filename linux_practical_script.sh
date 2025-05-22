#!/bin/bash

# Total questions
TOTAL=36
score=0

# Questions and answers array
questions=(
"Copy the file /etc/passwd to /tmp/passwd.bak."
"Move the file /tmp/passwd.bak to the directory /root/backups/."
"Use chage to set the password of user john to expire in 5 days."
"Change the ownership of the file /root/report.txt to user alice and group devops."
"Set read, write, and execute permissions for the owner, and no permissions for group and others on /root/secret.txt."
"Grant full permissions to a file /root/superfile.sh only for the root user."
"Apply an ACL to file /root/project.txt so that user david has read and write access."
"Modify the default umask value to 027 and create a new file to reflect the change."
"Create a new user named devadmin."
"Create a new group named ops_team."
"Create a user deploy with primary group ops_team."
"Create a user analyst with secondary group ops_team but a different primary group."
"Create a hard link to /root/data.txt named /root/data_hardlink.txt."
"Create a symbolic (soft) link to /root/data.txt named /root/data_softlink.txt."
"Display the first 15 lines of the file /etc/passwd."
"Display the last 7 lines of the file /etc/group."
"Create a file named devops_notes.txt inside /home/student/ and copy it to /var/tmp/."
"Move the file /var/tmp/devops_notes.txt to /opt/reports/."
"Set the file /opt/reports/devops_notes.txt so that only the group owner can read and write it."
"Set ownership of the directory /opt/reports to user manager and group qa_team."
"Add execute permission only for others on the file /usr/local/bin/startup.sh."
"Assign ACL permission to user sam to have execute-only access on /usr/local/bin/startup.sh."
"Change the umask value temporarily to 0022 and create a new directory secure_folder in /tmp."
"Create a group auditlog and a user loguser with that group as the primary group."
"Create a user support and add them to both auditlog and qa_team as secondary groups."
"Create a soft link to /var/log/syslog named /tmp/syslog_link and a hard link named /tmp/syslog_hard."
"Create a user named trainer with no home directory."
"Create a user named intern with /home/intern_data as the custom home directory."
"Modify the shell of user intern to /bin/bash."
"Lock the user account testuser."
"Unlock the user account testuser."
"Delete the user oldstaff and remove their home directory along with the account."
"Create a group named docker_users and assign user deploy to this group."
"Change the primary group of user developer to engineering."
"Add the user auditor to the groups compliance and security as secondary groups."
"List all the groups that user alice belongs to."
)

answers=(
"cp /etc/passwd /tmp/passwd.bak"
"mv /tmp/passwd.bak /root/backups/"
"chage -M 5 john"
"chown alice:devops /root/report.txt"
"chmod 700 /root/secret.txt"
"chmod 700 /root/superfile.sh"
"setfacl -m u:david:rw /root/project.txt"
"umask 027"
"useradd devadmin"
"groupadd ops_team"
"useradd -g ops_team deploy"
"useradd -G ops_team analyst"
"ln /root/data.txt /root/data_hardlink.txt"
"ln -s /root/data.txt /root/data_softlink.txt"
"head -n 15 /etc/passwd"
"tail -n 7 /etc/group"
"touch /home/student/devops_notes.txt && cp /home/student/devops_notes.txt /var/tmp/"
"mv /var/tmp/devops_notes.txt /opt/reports/"
"chmod 660 /opt/reports/devops_notes.txt"
"chown manager:qa_team /opt/reports"
"chmod o+x /usr/local/bin/startup.sh"
"setfacl -m u:sam:x /usr/local/bin/startup.sh"
"umask 0022 && mkdir /tmp/secure_folder"
"groupadd auditlog && useradd -g auditlog loguser"
"useradd -G auditlog,qa_team support"
"ln -s /var/log/syslog /tmp/syslog_link && ln /var/log/syslog /tmp/syslog_hard"
"useradd -M trainer"
"useradd -d /home/intern_data intern"
"usermod -s /bin/bash intern"
"passwd -l testuser"
"passwd -u testuser"
"userdel -r oldstaff"
"groupadd docker_users && usermod -a -G docker_users deploy"
"usermod -g engineering developer"
"usermod -a -G compliance,security auditor"
"groups alice"
)

echo "Linux Practical Exam: Answer the following questions with appropriate command(s):"
echo "-------------------------------------------------------------------------------"

for ((i=0; i<TOTAL; i++)); do
  echo ""
  echo "Q$((i+1)): ${questions[$i]}"
  read -p "Your answer: " user_answer
  # Normalize input (trim, lowercase)
  trimmed_answer=$(echo "$user_answer" | xargs)
  correct_answer=${answers[$i]}

  # Simple string equality check
  if [ "$trimmed_answer" == "$correct_answer" ]; then
    echo "Correct."
    ((score++))
  else
    echo "Wrong. Expected: $correct_answer"
  fi
done

percentage=$(( score * 100 / TOTAL ))
echo ""
echo "============================="
echo "Exam Completed."
echo "Score: $score out of $TOTAL"
echo "Percentage: $percentage %"

if [ $percentage -ge 60 ]; then
  echo "Result: PASS"
else
  echo "Result: FAIL"
fi
echo "============================="

