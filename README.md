# Deluge torrent client for Raspberry Pi (debian)

## Install

## Install method 1 (simpleton):

Just run install script with sudo and follow the instructions. There is a known issue.
If you enabled movies and series separator, after install you need to enable labelPlus plugin manually in deluge options.

```shell
sudo sh ./install.sh
```

## Install method 2 (for advanced users):

### Libtorrent

First of all, we need to install libtorrent with dpkg:

```shell
sudo dpkg -i ./libtorrent/libtorrent*
```

### Deluge

If libtorrent has been installed, we can go to the next step, install deluge.

First of all, install deluge build dependencies:

```shell
sudo apt-get install libboost-all-dev python python-twisted python-openssl python-setuptools intltool python-xdg python-chardet geoip-database python-libtorrent python-notify python-pygame python-glade2 librsvg2-common xdg-utils python-mako
```

Then go to the deluge folder:

```shell
cd ./deluge
```

#### Building and Installing Deluge

If you have run the build before, ensure you have a clean build environment:

```shell
python setup.py clean -a
```

Extract the source tarball and in the extracted folder run the build command:

```shell
python setup.py build
```

Install the package to your system:

```shell
sudo python setup.py install
```

For Linux Desktop systems an extra step is required due to an installer ​bug not copying data files, such as deluge.desktop:

```shell
sudo python setup.py install_data
```

#### Setup linux daemon:

Go back to the package folder:

```shell
cd ..
```

Then copy the service file to linux services folder, then make it runnable:

```shell
sudo cp ./daemon/deluge /etc/init.d/deluge && sudo chmod a+x /etc/init.d/deluge
```

Now open the service file and edit the user who will run the deluge:

```shell
sudo nano /etc/init.d/deluge
```

In this file search the `USER=YOUR_USERNAME` line and edit them, for example if you use osmc, change the user to `osmc` (`USER=osmc`)

To run deluge daemon at startup type this:

```shell
sudo update-rc.d deluge defaults
```

Finally restart the raspberry and enjoy deluge.
Note: The deluge config file will be created to the `user_that_you_wrote_in_deluge_daemon_file/.config/deluge`

## Setup (optional)

### Remote access

First of all you need to stop the deluge service:

```shell
sudo service deluge stop
```

Then you need to config the username and password in `~/.config/deluge/auth`. Default this file contains the auth data. Add a new line to the auth file and type your auth data the following format: `username:password:10` then enable remote access in `~/.config/deluge/core.conf` file, with the following option: `"allow_remote": true`.

After all you can start the deluge service:

```shell
sudo service deluge start
```

### Deluge-web connect localhost automatically

Default the deluge-web not connect the local daemon automatically.

First of all, you need to stop deluge service:

```shell
sudo service deluge stop
```

Than edit the `~/.config/deluge/web.conf` and set an option that name `default_daemon` and the parameter is the following: `"127.0.0.1:58846"`.

Finally, start the deluge service:

```shell
sudo service deluge start
```
