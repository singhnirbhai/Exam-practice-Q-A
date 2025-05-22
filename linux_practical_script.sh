#!/bin/bash

score=0
total=36

# Check 1: File copied
[ -f /tmp/passwd.bak ] && ((score++))

# Check 2: File moved
[ -f /root/backups/passwd.bak ] && ((score++))

# Check 3: chage value
[[ "$(chage -l john | grep 'Maximum')" == *"5"* ]] && ((score++))

# Check 4: Ownership
[[ "$(stat -c %U:%G /root/report.txt 2>/dev/null)" == "alice:devops" ]] && ((score++))

# Check 5: Permissions 700
[[ "$(stat -c %a /root/secret.txt 2>/dev/null)" == "700" ]] && ((score++))

# Check 6: root-only perms
[[ "$(stat -c %U /root/superfile.sh 2>/dev/null)" == "root" && "$(stat -c %a /root/superfile.sh 2>/dev/null)" == "700" ]] && ((score++))

# Check 7: ACL for david
getfacl /root/project.txt 2>/dev/null | grep -q "user:david:rw" && ((score++))

# Check 8: Umask change check
umask_val=$(umask)
[[ "$umask_val" == "0027" || "$umask_val" == "027" ]] && ((score++))

# Check 9: user exists
id devadmin &>/dev/null && ((score++))

# Check 10: group exists
getent group ops_team &>/dev/null && ((score++))

# Check 11: deploy user, primary group
[[ "$(id -gn deploy 2>/dev/null)" == "ops_team" ]] && ((score++))

# Check 12: analyst secondary group
id analyst 2>/dev/null | grep -q "ops_team" && ((score++))

# Check 13: Hard link
[[ "$(stat -c %i /root/data.txt 2>/dev/null)" == "$(stat -c %i /root/data_hardlink.txt 2>/dev/null)" ]] && ((score++))

# Check 14: Soft link
[ -L /root/data_softlink.txt ] && ((score++))

# Check 15: Head (not verifiable — skipped)
((score++)) # Give mark by default

# Check 16: Tail (not verifiable — skipped)
((score++)) # Give mark by default

# Check 17: File exists after copy
[ -f /var/tmp/devops_notes.txt ] && ((score++))

# Check 18: File moved
[ -f /opt/reports/devops_notes.txt ] && ((score++))

# Check 19: Group write-only perms
[[ "$(stat -c %a /opt/reports/devops_notes.txt 2>/dev/null)" == "660" ]] && ((score++))

# Check 20: Owner & group
[[ "$(stat -c %U:%G /opt/reports 2>/dev/null)" == "manager:qa_team" ]] && ((score++))

# Check 21: Others exec
[[ "$(stat -c %a /usr/local/bin/startup.sh 2>/dev/null)" =~ .*[1|5|7]$ ]] && ((score++))

# Check 22: ACL for sam execute-only
getfacl /usr/local/bin/startup.sh 2>/dev/null | grep -q "user:sam:--x" && ((score++))

# Check 23: Directory with correct umask
[ -d /tmp/secure_folder ] && ((score++))

# Check 24: Group + user
getent group auditlog &>/dev/null && id loguser &>/dev/null && ((score++))

# Check 25: support in multiple groups
id support 2>/dev/null | grep -q "auditlog" && id support | grep -q "qa_team" && ((score++))

# Check 26: Links to syslog
[ -L /tmp/syslog_link ] && [ -f /tmp/syslog_hard ] && ((score++))

# Check 27: trainer with no home
getent passwd trainer | cut -d: -f6 | grep -q "^/home" || ((score++))

# Check 28: intern with custom home
getent passwd intern | cut -d: -f6 | grep -q "/home/intern_data" && ((score++))

# Check 29: intern has bash shell
getent passwd intern | cut -d: -f7 | grep -q "/bin/bash" && ((score++))

# Check 30: testuser locked
passwd -S testuser 2>/dev/null | grep -q "L" && ((score++))

# Check 31: testuser unlocked
passwd -S testuser 2>/dev/null | grep -q "P" && ((score++))

# Check 32: user deleted
! id oldstaff &>/dev/null && ((score++))

# Check 33: deploy in docker_users
id deploy | grep -q "docker_users" && ((score++))

# Check 34: primary group of developer
id -gn developer 2>/dev/null | grep -q "engineering" && ((score++))

# Check 35: auditor in both
id auditor | grep -q "compliance" && id auditor | grep -q "security" && ((score++))

# Check 36: groups for alice
id alice &>/dev/null && ((score++))

# Show results
percent=$((score * 100 / total))
echo ""
echo "===================================="
echo "Automated Linux Exam Evaluation"
echo "Total Score: $score / $total"
echo "Percentage: $percent %"

if [ "$percent" -ge 60 ]; then
    echo "Result: PASS"
else
    echo "Result: FAIL"
fi
echo "===================================="
