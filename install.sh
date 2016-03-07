#!/bin/bash

# ~/.osx — Inspired from https://mths.be/osx

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# Keyboard / Mouse Pad
#

# Enable character repeat on keydown
defaults write -g ApplePressAndHoldEnabled -bool false

# Configure Desktop
defaults write com.apple.dock orientation right; # place Dock on the right side of screen
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2 # Set sidebar icon size to medium

# Menu bar: disable transparency
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName


#
# Install Xcode
#

echo "Checking Xcode..."

if [ ! -d "`xcode-select -p`" ]; then
   echo -n "Not found... Install it"

   # install Xcode Command Line Tools
   # https://github.com/chcokr/osx-init/blob/master/install.sh#L33
   # https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
   touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
   PROD=$(softwareupdate -l |
   grep "\*.*Command Line" |
   head -n 1 | awk -F"*" '{print $2}' |
   sed -e 's/^ *//' |
   tr -d '\n')
   softwareupdate -i "$PROD" -v;
else
   echo "OK"
fi

#
# Install Homebrew
#

echo -n "Install Homebrew..."
which -s brew
if [[ $? != 0 ]] ; then
    # Auto Install Homebrew
    # https://github.com/mxcl/homebrew/wiki/installation
    yes '' | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
else
    echo "Found updated it..."
    # Make sure we’re using the latest Homebrew.
    brew update
    # Upgrade any already-installed formulae.
    brew upgrade --all
fi

#
# Install Brew Packages
#

brew install \
   git \
   caskroom/cask/brew-cask \
   vim --override-system-vi \
   tccutil \
   dark-mode \
   dockutil \
   node \
   grep \
   zsh \
   zsh-completions


#
# Install Brew Cask Packages
#

sudo -v
echo 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' >> ~/.bash_profile
source ~/.bash_profile 

brew cask install \
    google-chrome \
    iterm2 \
    moom \
    1password \
    synology-cloud-station \
    dropbox \
    sequel-pro \
    hipchat \
    sourcetree \
    the-unarchiver
    vlc \
    skype \


# Quicklooks and helpers

sudo -v
brew cask install \
  quicklook-json \
  quicklook-csv \
  betterzipql \
  qlstephen \
  qlmarkdown \
  qlcolorcode \
  colorpicker-developer \
  colorpicker-hex \

# Need to be moved into /Applications to allow sandboxing and extensions to work
brew cask install google-chrome
rm /Applications/Google\ Chrome.app
sudo cp -R /opt/homebrew-cask/Caskroom/google-chrome/latest/Google\ Chrome.app /Applications



# Need to be moved into /Applications to allow sandboxing and extensions to work
brew cask install google-chrome
rm /Applications/Google\ Chrome.app
sudo cp -R /opt/homebrew-cask/Caskroom/google-chrome/latest/Google\ Chrome.app /Applications

# Modify OS X's accessibility database
sudo tccutil -i com.manytricks.Moom

# Switch Dock and Menu Bar to Dark mode
# https://github.com/sindresorhus/dark-mode
dark-mode --mode Dark

# Add Icon 
echo -n "Updating Dock..."

dockutil --remove "Contacts" --no-restart
dockutil --remove "Notes" --no-restart
dockutil --remove "Maps" --no-restart
dockutil --remove "FaceTime" --no-restart
dockutil --remove "Photo Booth" --no-restart
dockutil --remove "iBooks" --no-restart
dockutil --remove "App Store" --no-restart
dockutil --remove "Launchpad" --no-restart
dockutil --remove "Pages" --no-restart
dockutil --remove "Numbers" --no-restart
dockutil --remove "Keynote" --no-restart
dockutil --remove "iPhoto" --no-restart
dockutil --remove "Reminders" --no-restart
dockutil --remove "Microsoft Outlook" --no-restart
dockutil --remove "Microsoft Excel" --no-restart
dockutil --remove "Microsoft PowerPoint" --no-restart
dockutil --remove "Microsoft Word" --no-restart
dockutil --remove "Terminal" --no-restart

dockutil --add /Applications/Google\ Chrome.app --no-restart
dockutil --add /Applications/Firefox.app --no-restart
dockutil --add /Applications/Sequel\ Pro.app --no-restart
dockutil --add /Applications/Hipchat.app --no-restart
dockutil --add /Applications/Skype.app --no-restart
dockutil --add /Applications/iTerm.app --no-restart

killall Dock
echo "Done"

#
# Privacy
#

# fix-macosx by Landon Fuller
echo "• Applying fix-macosx by Landon Fuller"
git clone https://github.com/fix-macosx/fix-macosx ./fix-macosx
(cd ./fix-macosx && python fix-macosx.py)
rm -Rf ./fix-macosx

echo "Done. Note that some of these changes require a logout/restart to take effect."
