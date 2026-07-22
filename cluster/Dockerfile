# 1. הגדרת אימאג' הבסיס כפי שנדרש במשימה (Ubuntu 18.04)
FROM ubuntu:18.04

# 2. מניעת שאלות אינטראקטיביות בזמן ההתקנה (למשל בחירת אזור זמן שעלולה לתקוע את ה-Build)
ENV DEBIAN_FRONTEND=noninteractive

# 3. עדכון מאגר החבילות והתקנת השירותים הנדרשים
# apache2 -> שרת ה-Web
# corosync, pacemaker, pcs -> רכיבי הקלאסטר והניהול
# net-tools, iproute2, curl -> כלי רשת ודיבאג מומלצים לבדיקת כתובות IP
RUN apt-get update && apt-get install -y \
    apache2 \
    corosync \
    pacemaker \
    pcs \
    psmisc \
    net-tools \
    iproute2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 4. העתקת קובץ ה-index.html המעוצב שלנו למקום שבו Apache מגיש קבצים
COPY index.html /var/www/html/index.html

# 5. העתקת סקריפט ההפעלה של הקלאסטר ומתן הרשאות הרצה (chmod +x)
COPY setup-cluster.sh /usr/local/bin/setup-cluster.sh
RUN chmod +x /usr/local/bin/setup-cluster.sh

# 6. הגדרת הפקודה שתרוץ ברגע שהקונטיינר עולה
CMD ["/usr/local/bin/setup-cluster.sh"]