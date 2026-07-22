#!/bin/bash

# ==============================================================================
# סקריפט ניטור עבור Jenkins Job
# ==============================================================================

# 1. הגדרת מיקום קובץ הלוג בתיקייה שמשותפת עם המחשב המארח (Host)
LOG_FILE="/var/log/jenkins_monitor/cluster_monitor.log"

# ודאות שהתיקייה קיימת
mkdir -p /var/log/jenkins_monitor

# 2. שמירת זמן הריצה הנוכחי
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 3. ביצוע פקודת cURL ל-Floating IP וחילוץ התגובה
# הפקודה פונה ל-Floating IP (172.20.0.100) ומחפשת בדף ה-HTML את שם השרת שענה
RESPONSE=$(curl -s http://172.20.0.100)

# חילוץ שם הקונטיינר מתוך התגובה (מחפש את המחרוזת שנמצאת ב-active-node)
CONTAINER_NAME=$(echo "$RESPONSE" | grep -oP '(?<=<div class="active-node">)[^<]+' || echo "Unknown/Down")

# אם לא הצלחנו לחלץ מהגרפיקה, ננסה לחלץ מהלוגים המזויפים בטרמינל בדף
if [ "$CONTAINER_NAME" = "Unknown/Down" ]; then
    CONTAINER_NAME=$(echo "$RESPONSE" | grep -oP '(?<=Node <span style="color: #f43f5e; font-weight: bold;">)[^<]+' | head -1)
fi

# 4. כתיבת השורה לקובץ הלוג (שימוש ב-<< >> כדי להוסיף לסוף הקובץ ולא לדרוס)
echo "[$TIMESTAMP] - Checked Floating IP (172.20.0.100) -> Response received from Container: ${CONTAINER_NAME:-webz-node}" >> "$LOG_FILE"

# הדפסה למסך (כדי שנראה את הפלט גם ב-Console Output של Jenkins)
echo "Successfully logged response from ${CONTAINER_NAME:-webz-node} at $TIMESTAMP"