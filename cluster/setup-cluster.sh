#!/bin/bash

# ==============================================================================
# 1. עדכון שם המארח (Hostname) בדף ה-HTML
# ==============================================================================
# אנחנו שולפים את שם הקונטיינר הנוכחי (למשל webz-001) ומחליפים את ה-Placeholder
# בדף ה-HTML כדי שנראה בגרפיקה בדיוק מאיזה שרת התקבלה התשובה.
HOSTNAME=$(hostname)
sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" /var/www/html/index.html

# ==============================================================================
# 2. הפעלת שירות Apache2
# ==============================================================================
# מפעיל את שרת ה-Web כדי שיוכל להגיש את עמוד ה-HTML בפורט 80
service apache2 start

# ==============================================================================
# 3. יצירת קובץ ההגדרות של Corosync (corosync.conf)
# ==============================================================================
# Corosync מנהל את רשת התקשורת והדופק (Heartbeat) בין 3 השרתים בקלאסטר.
# הגדרנו שימוש ב פרוטוקול UDP Unicast (udpu) שמתאים במיוחד לסביבות Docker.
mkdir -p /etc/corosync
cat <<EOF > /etc/corosync/corosync.conf
totem {
    version: 2
    cluster_name: webz-cluster
    transport: udpu
}

nodelist {
    node {
        ring0_addr: webz-001
        nodeid: 1
    }
    node {
        ring0_addr: webz-002
        nodeid: 2
    }
    node {
        ring0_addr: webz-003
        nodeid: 3
    }
}

quorum {
    provider: corosync_votequorum
}

logging {
    to_logfile: yes
    logfile: /var/log/corosync/corosync.log
    to_syslog: yes
}
EOF

# ==============================================================================
# 4. התנעת שירותי ה-Cluster
# ==============================================================================
service corosync start
service pacemaker start

# ==============================================================================
# 5. הגדרת המשאב Floating IP ב-Pacemaker
# ==============================================================================
# Pacemaker מנהל את ה-Floating IP (כתובת IP וירטואלית: 172.20.0.100).
# כדי למנוע התנגשויות, רק שרת webz-001 יבצע את ההגדרה הראשונית של המשאב בקלאסטר.
if [ "$HOSTNAME" = "webz-001" ]; then
    # המתנה קצרה לוודא ששירות Pacemaker עלה לחלוטין בכל המכונות
    sleep 5

    # ביטול STONITH (מנגנון הגנה חומורתי שלא קיים בקונטיינרים של Docker)
    crm_attribute --type crm_config --name stonith-enabled --value false || true

    # הגדרת מדיניות Quorum - התעלמות מחוסר רוב במקרה שנפלו שרתים
    crm_attribute --type crm_config --name no-quorum-policy --value ignore || true

    # יצירת המשאב Floating IP והגדרת הכתובת הווירטואלית ל-172.20.0.100
    pcs resource create Cluster_VIP ocf:heartbeat:IPaddr2 ip=172.20.0.100 cidr_netmask=16 op monitor interval=10s || true
fi

# ==============================================================================
# 6. השארת הקונטיינר פעיל ברקע
# ==============================================================================
# קונטיינר של Docker נסגר מיד כשהפקודה הראשית שלו מסתיימת.
# הפקודה exec tail שומרת את הקונטיינר רץ ומזרימה לוגים.
exec tail -f /var/log/apache2/access.log /var/log/corosync/corosync.log