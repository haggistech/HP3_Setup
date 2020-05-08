#! /bin/bash


######################################
##### Dependencies #####
########################
echo
echo
echo "Create a build environment..."
cd /home/pi; mkdir develop

echo "Installing dependencies..."
apt update -y
apt-get update
apt-get upgrade -y
apt-get install -y git xserver-xorg cmake libflac-dev libogg-dev libvorbis-dev libavutil-dev libavcodec-dev libavformat-dev libavfilter-dev libswscale-dev libavresample-dev libopenal-dev libfreetype6-dev libudev-dev libjpeg-dev libudev-dev libfontconfig1-dev libglu1-mesa-dev libsfml-dev libxinerama-dev libcurl4-openssl-dev



################################
##### Install Attract Mode #####
################################

echo
echo
echo "Download and build Attract-Mode, This will take a little time...."
sleep 5
cd /home/pi/develop
git clone --depth 1 https://github.com/mickelson/attract attract
cd attract
make -j4 USE_XINERAMA=1 USE_LIBCURL=1
make -j4 install USE_XINERAMA=1 USE_LIBCURL=1
echo
echo
echo "Delete build files"
cd /home/pi; rm -r -f ./develop
echo
echo
echo "Attract Mode Installed"
sleep 5


cd /home/pi
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
./retropie_setup.sh

################################
##### Autostarts (systemd) #####
################################

echo
echo
echo "Setting Autostarts..."
cat > /lib/systemd/system/frontend-attractmode.service << EOL
[Unit]
Description=Run Attract Mode
After=multi-user.target

[Service]
ExecStart=startx /usr/local/bin/attract

[Install]
WantedBy=multi-user.target
EOL


cat > /lib/systemd/system/frontend-retropie.service << EOL
[Unit]
Description=Start RetroPie
After=network-online.target

[Service]
User=pi
WorkingDirectory=/home/pi
ExecStart=/usr/bin/emulationstation
StandardInput=tty-force
Restart=always

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable frontend-attractmode.service
cd /home/pi

##### Create Files #####
mkdir -p /home/pi/.attract/emulators
mkdir -p /home/pi/.attract/romlists
mkdir -p /home/pi/.attract/Attract\ Mode\ Setup

cat > /home/pi/.attract/Attract\ Mode\ Setup/Switch\ to\ AttractMode.sh << EOL
!# /bin/bash
echo "Switching to Attract Mode as Default boot"
sudo systemctl disable frontend-retropie.service
sudo systemctl enable frontend-attractmode.service
sudo reboot
EOL


cat > /home/pi/.attract/Attract\ Mode\ Setup/Switch\ to\ EmulationStation.sh << EOL
!# /bin/bash
echo "Switching to Attract Mode as Default boot"
sudo systemctl disable frontend-attractmode.service
sudo systemctl enable frontend-retropie.service
sudo reboot
EOL



cat > /home/pi/.attract/emulators/Attract\ Mode\ Setup.cfg << EOL
# Generated by Attract-Mode v2.6.1
#
executable           /bin/bash
args                 "[romfilename]"
rompath              /home/pi/.attract/Attract Mode Setup
romext               .sh
artwork    backart         /home/pi/.attract/Attract Mode Setup/backart
artwork    boxart          /home/pi/.attract/Attract Mode Setup/boxart
artwork    cartart         /home/pi/.attract/Attract Mode Setup/cartart
artwork    flyer           /home/pi/.attract/Attract Mode Setup/flyer
artwork    marquee         /home/pi/.attract/Attract Mode Setup/marquee
artwork    snap            /home/pi/.attract/Attract Mode Setup/snap
artwork    wheel           /home/pi/.attract/Attract Mode Setup/wheel
EOL


cat > /home/pi/.attract/romlists/Attract\ Mode\ Setup.txt << EOL
#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons;Series;Language;Region;Rating
Switch to EmulationStation;Switch to EmulationStation;Attract Mode Setup;;;;;;;;;;;;;;;;;;
EOL



cat > /home/pi/.attract/attract.cfg << EOL
# Generated by Attract-Mode v2.6.1
#
display	Attract Mode Setup
	layout               Attrac-Man
	romlist              Attract Mode Setup
	in_cycle             yes
	in_menu              yes
	filter               All
	filter               Favourites
		rule                 Favourite equals 1

sound
	sound_volume         100
	ambient_volume       100
	movie_volume         100

input_map
	configure            Tab
	prev_letter          LControl+Up
	next_letter          LControl+Down
	filters_menu         LControl+Left
	next_filter          LControl+Right
	configure            Escape+Up
	edit_game            Escape+Down
	add_favourite        Escape+LControl
	prev_letter          Joy0 Up+Joy0 Button0
	next_letter          Joy0 Down+Joy0 Button0
	filters_menu         Joy0 Left+Joy0 Button0
	next_filter          Joy0 Right+Joy0 Button0
	configure            Joy0 Up+Joy0 Button1
	edit_game            Joy0 Down+Joy0 Button1
	add_favourite        Joy0 Button0+Joy0 Button1
	back                 Escape
	back                 Joy0 Button1
	up                   Up
	up                   Joy0 Up
	down                 Down
	down                 Joy0 Down
	left                 Left
	left                 Joy0 Left
	right                Right
	right                Joy0 Right
	select               Return
	select               LControl
	select               Joy0 Button0
	default             back	exit
	default             up	prev_game
	default             down	next_game
	default             left	prev_display
	default             right	next_display

general
	language             en
	exit_command         
	exit_message         
	default_font         FreeSans
	font_path            /usr/share/fonts/;$HOME/.fonts/
	screen_saver_timeout 600
	displays_menu_exit   yes
	hide_brackets        no
	startup_mode         default
	confirm_favourites   yes
	confirm_exit         yes
	mouse_threshold      10
	joystick_threshold   75
	window_mode          fullscreen
	filter_wrap_mode     default
	track_usage          yes
	multiple_monitors    no
	smooth_images        yes
	selection_max_step   128
	selection_speed_ms   40
	move_mouse_on_launch yes
	scrape_snaps         yes
	scrape_marquees      yes
	scrape_flyers        yes
	scrape_wheels        yes
	scrape_fanart        no
	scrape_videos        no
	scrape_overview      yes
	thegamesdb_key       
	video_decoder        
	menu_prompt          Displays Menu
	menu_layout          
EOL

################
##### Misc #####
################

echo
echo
echo "Setting AutoLogin"
wget https://raw.githubusercontent.com/RPi-Distro/raspi-config/master/autologin%40.service -o /lib/systemd/system/autologin%40.service
systemctl daemon-reload
systemctl enable autologin@.service
echo
echo
echo "Fixing Permissions on Files..."
echo
echo
echo "Romlists...."
chown -R pi:pi /home/pi/.attract/romlists
echo
echo
echo "AM Setup...."
chown -R pi:pi /home/pi/.attract/Attract\ Mode\ Setup
echo
echo
echo "Emulators...."
chown -R pi:pi /home/pi/.attract/emulators
echo
echo
echo "Setting scripts to executable...."
chmod +x /home/pi/.attract/Attract\ Mode\ Setup/*.sh
echo
echo
echo "Disabling Boot Text...."
sed -i 's/console=tty1/console=tty3/g' /boot/cmdline.txt
echo
echo
echo "Disabling RPI Logo...."
sed -i 's/$/ logo.nologo/' /boot/cmdline.txt
echo
echo
echo "Disabling Rainbow Splash...."
echo "disable_splash=1" >> /boot/config.txt
echo
echo
echo "Adding Auto Expand...."
sed -i 's#$# init=/usr/lib/raspi-config/init_resize.sh#' /boot/cmdline.txt
echo
echo
echo "Complete"
echo
echo
echo "System will now Reboot...."
sleep 3
reboot
