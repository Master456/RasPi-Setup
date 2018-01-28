#!bin/bash
input () {
  echo "Getting settings ..."
  read -p "Do You want to disable IPv6 globaly? (y/n) " ipv6
}

run () {
  step1
  step2
}

step1 () {
  echo "Step 1 of 5: Installing updates ..."
  if [ "$ipv6" = "y" ]
    then sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && sudo sysctl -p
  fi
  sudo apt update
  sudo apt -y full-upgrade
}

step2 () {
  echo "Step 2 of 5: Installing the needed programms ..."
  sudo apt -y install hostapd bridge-utils git
  echo "Getting additional files ..."
  git clone https://github.com/Master456/RasPi-Einrichtung.git /home/pi/RasPi-Einrichtung
}

input
run
echo "Run: 'sudo sh /home/pi/RasPi-Einrichtung/setup_part2.sh' to continue."
exit
