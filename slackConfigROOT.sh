#!/bin/sh

# wget -N https://raw2.github.com/ryanpcmcquen/config-o-matic/master/slackConfigROOT.sh; sh slackConfigROOT.sh; rm slackConfigROOT.sh

## BASHGITVIM="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/bashGitVimROOT.sh"

## set config files here:
SBOPKGDL="http://sbopkg.googlecode.com/files/sbopkg-0.37.0-noarch-1_cng.tgz"
SPPLUSDL="http://sourceforge.net/projects/slackpkgplus/files/slackpkg%2B-1.3.1-noarch-4mt.txz"
SPPLUSCONF64="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/64/slackpkgplus.conf"
SPPLUSCONF32="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/32/slackpkgplus.conf"

SPPLUSMATECONF64="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/64/slackpkgplus.conf"
SPPLUSMATECONF32="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/32/slackpkgplus.conf"


INSCRPT="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/initscript"

BASHRC="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bashrc"
BASHPR="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bash_profile"

VIMRC="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/.vimrc"

GITNAME="Ryan Q"
GITEMAIL="ryan.q@linux.com"

TOUCHPCONF="https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/51-synaptics.conf"


if [ ! $UID = 0 ]; then
  cat << EOF
This script must be run as root.
EOF
  exit 1
fi


read -r -p "Would you like to become NEARFREE? \
(follows freeslack.net, but keeps kernel, not valid with other options) \
[y/N]: " response
case $response in
  [yY][eE][sS]|[yY])
    export NEARFREE=true;
    echo You are becoming NEARFREE.;
    ;;
  *)
    echo You are not becoming NEARFREE.;
    ;;
esac


if [ "$NEARFREE" != true ]; then
  read -r -p "Would you like to go VANILLA? [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      export VANILLA=true;
      echo You are going VANILLA.;
      ;;
    *)
      echo You are not going VANILLA.;
      ;;
  esac
fi


if [ "$NEARFREE" != true ]; then
  read -r -p "Would you like to install Mate? [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      export MATE=true;
      echo You have chosen to install Mate.;
      ;;
    *)
      echo You are not installing Mate.;
      ;;
  esac
fi

## configure lilo
sed -i 's/^#compact/lba32\
compact/g' /etc/lilo.conf

## set to utf8 console if not set in install
sed -i 's/^append=" vt.default_utf8=0"/append=" vt.default_utf8=1"/g' /etc/lilo.conf

sed -i 's/^timeout = 50/timeout = 5/g' /etc/lilo.conf
sed -i 's/^timeout = 1200/timeout = 5/g' /etc/lilo.conf

lilo

## change to utf-8 encoding
sed -i 's/^export LANG=en_US/#export LANG=en_US/g' /etc/profile.d/lang.sh
sed -i 's/^#export LANG=en_US.UTF-8/export LANG=en_US.UTF-8/g' /etc/profile.d/lang.sh


## adjust slackpkg blacklist
sed -i 's/^aaa_elflibs/#aaa_elflibs/g' /etc/slackpkg/blacklist

sed -i 's/#\[0-9]+_SBo/\
\[0-9]+_SBo\
sbopkg/g' /etc/slackpkg/blacklist


### undo 14.1 mirrors
sed -i 's_^http://ftp.osuosl.org/.2/slackware/slackware-14.1/_# http://ftp.osuosl.org/.2/slackware/slackware-14.1/_g' /etc/slackpkg/mirrors
sed -i 's_^http://ftp.osuosl.org/.2/slackware/slackware64-14.1/_# http://ftp.osuosl.org/.2/slackware/slackware64-14.1/_g' /etc/slackpkg/mirrors
### osuosl mirrors are stable and fast (they are used for the changelogs), choose mirrorbrain if you are far from oregon
sed -i 's_^# http://ftp.osuosl.org/.2/slackware/slackware-current/_http://ftp.osuosl.org/.2/slackware/slackware-current/_g' /etc/slackpkg/mirrors
sed -i 's_^# http://ftp.osuosl.org/.2/slackware/slackware64-current/_http://ftp.osuosl.org/.2/slackware/slackware64-current/_g' /etc/slackpkg/mirrors


wget -N $BASHRC -P ~/
wget -N $BASHPR -P ~/


wget -N $VIMRC -P ~/


## set tmux scrollback value
tmux set-option -g history-limit 9999


## git config
git config --global user.name "$GITNAME"
git config --global user.email "$GITEMAIL"
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple
git config --global core.pager "less -r"


wget -N $TOUCHPCONF -P /etc/X11/xorg.conf.d/

wget -N $SBOPKGDL -P ~/
if [ "$NEARFREE" != true ]; then
  wget -N $SPPLUSDL -P ~/
fi

installpkg ~/*.t?z

mv /etc/slackpkg/slackpkgplus.conf /etc/slackpkg/slackpkgplus.conf.old

if [ "$( uname -m )" = "x86_64" ] && [ "$NEARFREE" != true ]; then
  if [ "$MATE" = true ]; then
    wget -N $SPPLUSMATECONF64 -P /etc/slackpkg/
  else
    wget -N $SPPLUSCONF64 -P /etc/slackpkg/
  fi
elif [ "$NEARFREE" != true ]; then
  if [ "$MATE" = true ]; then
    wget -N $SPPLUSMATECONF32 -P /etc/slackpkg/
  else
    wget -N $SPPLUSCONF32 -P /etc/slackpkg/
  fi
fi

rm ~/*.t?z

wget -N $INSCRPT -P /etc/

if [ "$NEARFREE" = true ]; then
  removepkg getty-ps lha unarj zoo amp \
  bluez-firmware ipw2100-fw ipw2200-fw trn \
  zd1211-firmware xfractint xgames xv

  ## set slackpkg to non-interactive mode to run without prompting
  sed -i 's/^BATCH=off/BATCH=on/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/g' /etc/slackpkg/slackpkg.conf
  
  slackpkg blacklist getty-ps lha unarj zoo amp \
  bluez-firmware ipw2100-fw ipw2200-fw trn \
  zd1211-firmware xfractint xgames xv

  echo "You have become NEARFREE, to update your kernel, head to freeslack.net."

elif [ "$VANILLA" = true ]; then
  echo "You have gone VANILLA."
else
  ## set slackpkg to non-interactive mode to run without prompting
  sed -i 's/^BATCH=off/BATCH=on/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/g' /etc/slackpkg/slackpkg.conf

  slackpkg update gpg && \
  slackpkg update && \
  slackpkg install-new && \
  slackpkg upgrade-all

  slackpkg install wicd ffmpeg vlc chromium

  chmod -x /etc/rc.d/rc.networkmanager
  sed -i 's/^\([^#]\)/#\1/g' /etc/rc.d/rc.inet1.conf
  sed -i 's/^\([^#]\)/#\1/g' /etc/rc.d/rc.wireless.conf

  ## ntp cron job (the bad way)
  #wget -N https://raw2.github.com/ryanpcmcquen/linuxTweaks/master/slackware/clocksync -P /etc/cron.daily/

  ## set up ntp daemon (the good way)
  /etc/rc.d/rc.ntpd stop
  ntpdate 0.pool.ntp.org
  ntpdate 1.pool.ntp.org
  hwclock --systohc
  sed -i 's/#server pool.ntp.org iburst / \
  server 0.pool.ntp.org iburst \
  server 1.pool.ntp.org iburst \
  server 2.pool.ntp.org iburst \
  server 3.pool.ntp.org iburst \
  /g' /etc/ntp.conf
  chmod +x /etc/rc.d/rc.ntpd
  /etc/rc.d/rc.ntpd start

  ## create sbopkg directories
  mkdir -pv /var/lib/sbopkg/SBo/14.1/
  mkdir -pv /var/lib/sbopkg/queues/
  mkdir -pv /var/log/sbopkg/
  mkdir -pv /var/cache/sbopkg/
  mkdir -pv /tmp/SBo/
  ## reverse
  #rm -rfv /var/lib/sbopkg/
  #rm -rfv /var/log/sbopkg/
  #rm -rfv /var/cache/sbopkg/
  #rm -rfv /tmp/SBo/
  ## check for sbopkg update,
  ## then sync the slackbuilds.org repo
  sbopkg -B -u
  sbopkg -B -r


  if [ -z "$( ls /var/log/packages/ | grep superkey-launch )" ]; then
    sbopkg -B -i superkey-launch
  fi

  if [ -z "$( ls /var/log/packages/ | grep lxterminal )" ]; then
    sbopkg -B -i lxterminal
  fi

  if [ -z "$( ls /var/log/packages/ | grep dwm )" ]; then
    sbopkg -B -i dwm
  fi

  if [ -z "$( ls /var/log/packages/ | grep dmenu )" ]; then
    sbopkg -B -i dmenu
  fi

  ## this library is necessary for some games,
  ## doesn't hurt to have it  ; ^)
  if [ -z "$( ls /var/log/packages/ | grep libtxc_dxtn )" ]; then
    sbopkg -B -i libtxc_dxtn
  fi

  ## file syncing service
  if [ -z "$( ls /var/log/packages/ | grep copy )" ]; then
    sbopkg -B -i copy
  fi

  ## because QtCurve looks amazing
  if [ ! -z "$( ls /var/log/packages/ | grep kdelibs )" ]; then
    if [ -z "$( ls /var/log/packages/ | grep QtCurve-KDE4 )" ]; then
      sbopkg -B -i QtCurve-KDE4
    fi
  fi
  
  if [ -z "$( ls /var/log/packages/ | grep QtCurve-Gtk2 )" ]; then
    sbopkg -B -i QtCurve-Gtk2
  fi

  ## numix icons are dead sexy
  git clone https://github.com/numixproject/numix-icon-theme.git
  mv ./numix-icon-theme/Numix/ /usr/share/icons/
  rm -rf ./numix-icon-theme/

  git clone https://github.com/numixproject/numix-icon-theme-circle.git
  mv ./numix-icon-theme-circle/Numix-Circle/ /usr/share/icons/
  rm -rf ./numix-icon-theme-circle/

  git clone https://github.com/shimmerproject/Numix.git
  mv ./Numix/ /usr/share/themes/
  rm -rf ./Numix/

  wget -N https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.colors -P /usr/share/apps/color-schemes/
  mv /usr/share/apps/color-schemes/Numix.colors /usr/share/apps/color-schemes/Numix-KDE.colors
  wget -N https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.qtcurve -P /usr/share/apps/QtCurve/
  mv /usr/share/apps/QtCurve/Numix.qtcurve /usr/share/apps/QtCurve/Numix-KDE.qtcurve

  ## get caledonia wallpapers, who doesn't like nice wallpapers?
  wget -N http://sourceforge.net/projects/caledonia/files/Caledonia%20Official%20Wallpapers/Caledonia_Official_Wallpaper_Collection-1.5.tar.gz -P ~/
  tar xf ~/Caledonia_Official_Wallpaper_Collection-1.5.tar.gz
  cp -r ~/Caledonia_Official_Wallpaper_Collection/* /usr/share/wallpapers/
  rm -rf ~/Caledonia_Official_Wallpaper_Collection/
  rm ~/Caledonia_Official_Wallpaper_Collection-1.5.tar.gz

fi


if [ "$MATE" = true ] && [ "$NEARFREE" != true ]; then
  slackpkg install msb
fi


## set slackpkg back to normal
sed -i 's/^BATCH=on/BATCH=off/g' /etc/slackpkg/slackpkg.conf
sed -i 's/^DEFAULT_ANSWER=y/DEFAULT_ANSWER=n/g' /etc/slackpkg/slackpkg.conf


echo
echo
echo "************************************"
echo "********** CONFIG-O-MATIC **********"
echo "************************************"
echo
echo "Your system is now set to UTF-8."
echo "(e.g. You should use uxterm, instead of xterm)."
echo "Thank you for using config-o-matic!"
echo "You should now run 'adduser', if you have not."
echo "Then you should run the $ user script."
echo




