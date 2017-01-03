#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	dialog --backtitle "Deluge install" --title "Error" --msgbox "To install deluge you need to be root." 0 0
	exit 1
fi

exec 3>&1;
delugeuser=$(dialog --backtitle "Deluge install" --title "Daemon user" --inputbox 'Please enter the user who will run the deluge daemon.' 0 0 $SUDO_USER 2>&1 1>&3);
exitcode=$?;
exec 3>&-;

if [ "$exitcode" != "0" ]; then
	exit 1
fi

if dialog --backtitle "Deluge install" --title "Daemon remote access" --yesno 'Do you want to enable the deluge remote access?' 0 0 ;then
    remoteenable=1
    exec 3>&1;
    delugedaemonuser=$(dialog --backtitle "Deluge install" --title "Daemon remote username" --inputbox 'Please enter deluge daemon username.' 0 0 'deluge' 2>&1 1>&3);
    exitcode=$?;
    exec 3>&-;
    exec 3>&1;
    delugedaemonpass=$(dialog --backtitle "Deluge install" --title "Daemon remote password" --inputbox 'Please enter deluge daemon password.' 0 0 'deluge' 2>&1 1>&3);
    exitcode=$?;
    exec 3>&-;
else
    remoteenable=0
fi

apt-get update && dpkg -i ./libtorrent/libtorrent* && apt-get install libboost-all-dev python python-twisted python-openssl python-setuptools intltool python-xdg python-chardet geoip-database python-libtorrent python-notify python-pygame python-glade2 librsvg2-common xdg-utils python-mako && cd ./deluge && python setup.py clean -a && python setup.py build && python setup.py install && python setup.py install_data && cd .. && cp ./daemon/deluge /etc/init.d/deluge && sed -i -e 's/YOUR_USERNAME/'"$delugeuser"'/g' /etc/init.d/deluge && chmod a+x /etc/init.d/deluge && update-rc.d deluge defaults && service deluge start;

if [ "$remoteenable" != "0" ]; then
    service deluge stop && echo "$delugedaemonuser:$delugedaemonpass:10" > "$(eval echo ~$delugeuser)/.config/deluge/auth" && sed -i -e 's/\"allow_remote\"\: false/\"allow_remote\"\: true/g' "$(eval echo ~$delugeuser)/.config/deluge/core.conf" && service deluge start;
fi
