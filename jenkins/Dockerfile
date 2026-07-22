# 1. שימוש באימאג' הרשמי והעדכני של Jenkins
FROM jenkins/jenkins:lts-jdk17

# 2. מעבר למשתמש root כדי להתקין חבילות במערכת
USER root

# 3. התקנת curl ו-grep מתקדם (pcregrep/perl) לצורך ניתוח התשובות בסקריפט
RUN apt-get update && apt-get install -y \
    curl \
    grep \
    && rm -rf /var/lib/apt/lists/*

# 4. יצירת תיקיית הלוגים ומתן הרשאות מלאות למשתמש jenkins
RUN mkdir -p /var/log/jenkins_monitor && chown -R jenkins:jenkins /var/log/jenkins_monitor

# 5. העתקת סקריפט הניטור ומתן הרשאות הרצה
COPY monitor.sh /usr/local/bin/monitor.sh
RUN chmod +x /usr/local/bin/monitor.sh

# 6. החזרת המשתמש למשתמש ברירת המחדל של Jenkins (אבטחה נכונה)
USER jenkins