#!/bin/bash

# Superuser check
if [ "$(id -u)" != "0" ]; then
	dialog --backtitle "Deluge install" --title "Error" --msgbox "To install deluge you need to be root." 0 0
	exit 1
fi

# Get the user who will run deluge
dialogbacktitle="Deluge install - step 1 / 4 (username)";
delugeuser=$(dialog --backtitle "$dialogbacktitle" --title "Daemon username" --inputbox 'Please enter username who will run the deluge daemon.' 0 0 $SUDO_USER 3>&1 1>&2 2>&3 3>&-);

# If user if not defined break the script
if [ "$delugeuser" == "" ]; then
	exit 1
fi

# Get download location
dialogbacktitle="Deluge install - step 2 / 4 (download loaction)";
delugedownloadpath=$(dialog --backtitle "$dialogbacktitle" --title "Daemon downloan path" --inputbox 'Please enter download location path.' 0 0 '/mnt/usbhdd/torrent' 3>&1 1>&2 2>&3 3>&-);

# If deluge service running, stop them
sudo service deluge stop;

# Put deluge config path to a variable
delugeconfigpath=$(eval echo ~$delugeuser)"/.config/deluge";


# Ask to remote access
dialogbacktitle="Deluge install - step 3 / 4 (remote access)";
if dialog --backtitle "$dialogbacktitle" --title "Daemon remote access" --yesno 'Do you want to enable the deluge remote access?' 0 0; then
    delugedaemonuser=$(dialog --backtitle "$dialogbacktitle" --title "Daemon remote username" --inputbox 'Please enter deluge daemon username.' 0 0 'deluge' 3>&1 1>&2 2>&3 3>&-);
    delugedaemonpass=$(dialog --backtitle "$dialogbacktitle" --title "Daemon remote password" --inputbox 'Please enter deluge daemon password.' 0 0 'deluge' 3>&1 1>&2 2>&3 3>&-);  
fi

# Ask to download movies and series separate folders
dialogbacktitle="Deluge install - step 4 / 4 (label plus)";
if dialog --backtitle "$dialogbacktitle" --title "Label movies and series" --yesno 'Do you want to enable label plus to separate movies and series directory?' 0 0; then
    autolabelmoviespath=$(dialog --backtitle "$dialogbacktitle" --title "Label plus moives path" --inputbox 'Please enter movies download path.' 0 0 '/mnt/usbhdd/torrent/movies' 3>&1 1>&2 2>&3 3>&-);
    autolabelseriespath=$(dialog --backtitle "$dialogbacktitle" --title "Label plus series path" --inputbox 'Please enter series download path.' 0 0 '/mnt/usbhdd/torrent/series' 3>&1 1>&2 2>&3 3>&-);  
fi

# Run the big install ;)
apt-get update && dpkg -i ./libtorrent/libtorrent* && apt-get install libboost-all-dev python python-twisted python-openssl python-setuptools intltool python-xdg python-chardet geoip-database python-libtorrent python-notify python-pygame python-glade2 librsvg2-common xdg-utils python-mako && cd ./deluge && python setup.py clean -a && python setup.py build && python setup.py install && python setup.py install_data && cd .. && cp ./daemon/deluge /etc/init.d/deluge && sed -i -e "s#YOUR_USERNAME#${delugeuser}#g" /etc/init.d/deluge && chmod a+x /etc/init.d/deluge && update-rc.d deluge defaults && sudo service deluge start && sleep 10;

sudo -u $delugeuser deluge-console "config -s download_location $delugedownloadpath"

if [ "$delugedaemonuser" != "" ] && [ "$delugedaemonpass" != "" ]; then
	echo "remote daemon";
	echo "$delugedaemonuser:$delugedaemonpass:10" > "$delugeconfigpath/auth" && \
	sudo -u $delugeuser deluge-console "config -s allow_remote True" && \
	echo "Remote access setup done!";
fi

if [ "$autolabelmoviespath" != "" ] && [ "$autolabelseriespath" != "" ]; then
	cp ./labelplus/LabelPlus-0.3.2.2-py2.7.egg "$delugeconfigpath/plugins/LabelPlus-0.3.2.2-py2.7.egg" && \
	cp ./labelplus/labelplus.conf "$delugeconfigpath/labelplus.conf" && \
	sed -i -e "s#path_movies#${autolabelmoviespath}#g" "$delugeconfigpath/labelplus.conf" && \
	sed -i -e "s#path_series#${autolabelseriespath}#g" "$delugeconfigpath/labelplus.conf" && \
	sudo -u $delugeuser deluge-console "plugin -e LabelPlus" && \
	echo "Label plus setup done!";
fi

sudo service deluge restart;
