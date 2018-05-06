#!/usr/bin/env bash
# Error codes:
# 1 - No root privilege
# 2 - Error when downloading file
# 3 - No input

echo "gdut-drcom Installation Script by CYRO4S"
echo ""
echo "GitHub:      https://github.com/CYRO4S/gdut-drcom"
echo "Forked From: https://github.com/chenhaowen01/gdut-drcom"
echo "Special thanks to @chenhaowen01"
echo ""
echo ""

# Check for root privilege
if [ $UID -ne 0 ]; then
  echo -e "\033[41;37mRoot privilege required to execute this script. \033[0m"
  echo -e "\033[41;37mUse \"sudo bash $0\" instead. \033[0m"
  exit 1
fi

# Get Drcom IP from input
echo "Provide Drcom server IP address:"
read IPADDR
if [[ -z $IPADDR ]]; then
  echo -e "\033[41;37mDrcom server IP address is required to setup service. \033[0m"
  exit 3
fi
echo "Drcom server IP is set to: $IPADDR."
echo ""

# Check for hardware architecture
ARCH="amd64"
[ -n "`uname -a | grep "x86_64"`" ] && ARCH="amd64"
[ -n "`uname -a | grep "i386"`" ] && ARCH="i386"
[ -n "`uname -a | grep "i686"`" ] && ARCH="i386"
[ -n "`uname -a | grep "armv7l"`" ] && ARCH="armhf"
echo "Your hardware architecture is $ARCH."

# Download the app
echo "Downloading gdut-drcom..."
wget --no-check-certificate https://github.com/CYRO4S/gdut-drcom/releases/download/1.6.8/gdut-drcom-linux-$ARCH -O /usr/bin/gdut-drcom  >/dev/null 2>&1
echo -n "Validating... "
if [[ -f /usr/bin/gdut-drcom ]]; then
  echo "Found /usr/bin/gdut-drcom"
  chmod a+x /usr/bin/gdut-drcom >/dev/null 2>&1
else
  echo -e "\033[41;37mAn error occured when downloading required file. \033[0m"
  echo -e "\033[41;37mCheck your Internet connection and try again. \033[0m"
  exit 2
fi

# Configurate service
echo "Configurating service..."
cat > /lib/systemd/system/gdut-drcom.service<<-EOF
  [Unit]
  Description=Drcom Service
  After=network.target
  Wants=network.target

  [Service]
  Type=simple
  PIDFile=/var/run/gdut-drcom.pid
  ExecStart=/usr/bin/gdut-drcom --remote-ip $IPADDR
  Restart=on-failure

  [Install]
  WantedBy=multi-user.target
EOF
echo -n "Validating... "
if [[ -f /lib/systemd/system/gdut-drcom.service ]]; then
  echo "Found /lib/systemd/system/gdut-drcom.service"
else
  echo -e "\033[41;37mAn error occured when configurating service. \033[0m"
  echo -e "\033[41;37mMake sure root can write to /lib/systemd/system/. \033[0m"
  exit 2
fi

# Enable the service and start it.
echo "Starting gdut-drcom service..."
systemctl enable gdut-drcom.service >/dev/null 2>&1
systemctl start gdut-drcom.service >/dev/null 2>&1

# Done.
echo "Done."
