#!/bin/sh

# cd; wget -N https://raw.githubusercontent.com/ryanpcmcquen/config-o-matic/master/slackConfigROOT.sh; sh slackConfigROOT.sh; rm slackConfigROOT.sh

## BASHGITVIM="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/bashGitVimROOT.sh"

## added in 4.2.0
## note that some configuration options may not match
## depending on the system, as config-o-matic tries
## to avoid overwriting most files
CONFIGOMATICVERSION=5.9.29


if [ ! $UID = 0 ]; then
  cat << EOF
This script must be run as root.
EOF
  exit 1
fi


## versions!
cd
## get stable version number
wget www.slackware.com -O slackware-home-page.html -P ~/
cat ~/slackware-home-page.html | grep "is released!" | head -1 | sed 's/Slackware//g' | sed 's/is released!//g' | sed 's/ //g' > ~/SlackwareStableVersion
rm ~/slackware-home-page.html

export SLACKSTAVER=${SLACKSTAVER="$( tr -d '\n\r' < ~/SlackwareStableVersion )"}
export DASHSLACKSTAVER=${DASHSLACKSTAVER=-"$( tr -d '\n\r' < ~/SlackwareStableVersion )"}

MSBVER=1.8

## set config files here:
SBOPKGDL="http://sbopkg.googlecode.com/files/sbopkg-0.37.0-noarch-1_cng.tgz"
SPPLUSDL="http://sourceforge.net/projects/slackpkgplus/files/slackpkg%2B-1.3.3-noarch-1mt.txz"

INSCRPT="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/initscript"

BASHRC="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bashrc"
BASHPR="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bash_profile"

VIMRC="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/.vimrc"
VIMCOLOR="https://raw.githubusercontent.com/ryanpcmcquen/vim-plain/master/colors/vi-clone.vim"

TMUXCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/tmux.conf"

GITNAME="Ryan P.C. McQuen"
GITEMAIL="ryan.q@linux.com"

TOUCHPCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/51-synaptics.conf"

ASOUNDCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/asound.conf"

GETEXTRASTA="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getExtraSlackBuildsSTABLE.sh"
GETEXTRACUR="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getExtraSlackBuildsCURRENT.sh"

GETSOURCESTA="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getSystemSlackBuildsSTABLE.sh"
GETSOURCECUR="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getSystemSlackBuildsCURRENT.sh"

GETJAVA="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getJavaSlackBuild.sh"

CALPLAS="Caledonia-1.9.tar.gz"
CALWALL="Caledonia_Official_Wallpaper_Collection-1.5.tar.gz"

## eric hameleers has updated multilib to include this package
#LIBXSHM="libxshmfence-1.1-i486-1.txz"

## my shell functions  ;^)
no_prompt_sbo_pkg_install() {
  SBO_PACKAGE=$1
  if [ ! -e /var/log/packages/$SBO_PACKAGE-* ]; then
    echo p | sbopkg -B -e continue -i $SBO_PACKAGE
  fi
}

slackpkg_update_only() {
  slackpkg update gpg
  slackpkg update
}

slackpkg_full_upgrade() {
  slackpkg_update_only
  slackpkg install-new
  slackpkg upgrade-all
}

set_slackpkg_to_auto() {
  sed -i 's/^BATCH=off/BATCH=on/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/g' /etc/slackpkg/slackpkg.conf
}

set_slackpkg_to_manual() {
  sed -i 's/^BATCH=on/BATCH=off/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=y/DEFAULT_ANSWER=n/g' /etc/slackpkg/slackpkg.conf
}
##

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i486 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

## make sure we are home  ;^)
cd

if [ ! -z "$( aplay -l | grep Analog | grep 'card 1' )" ]; then
  wget -N $ASOUNDCONF -P /etc/
fi

## sound fix for steam
ln -sfv /etc/machine-id /var/lib/dbus/machine-id


echo
echo
echo "*************************************************************"
echo "*************************************************************"
echo "********          WELCOME TO                         ********"
echo "********              CONFIG-O-MATIC                 ********"
echo "*************************************************************"
echo "*************************************************************"
echo
echo

## go!

read -p "Would you like to switch to -CURRENT? \
 (NO = STABLE) \
 [y/N]: " response
case $response in
  [yY][eE][sS]|[yY])
    export CURRENT=true;
    echo You are switching to -CURRENT.;
    ;;
  *)
    echo You are going STABLE.;
    ;;
esac

read -p "Would you like to install WICD? \
 (NetworkManager will be disabled) \
 [y/N]: " response
case $response in
  [yY][eE][sS]|[yY])
    export WICD=true;
    echo You are installing WICD.;
    ;;
  *)
    echo You are not installing WICD.;
    ;;
esac

read -p "Would you like to install a bunch of MISCELLANY?  [y/N]: " response
case $response in
  [yY][eE][sS]|[yY])
    export MISCELLANY=true;
    echo You are installing MISCELLANY.;
    ;;
  *)
    echo You are going VANILLA.;
    ;;
esac

if [ "$( uname -m )" = "x86_64" ]; then
  read -p "Would you like to go MULTILIB?  [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      export MULTILIB=true;
      echo You have chosen to go MULTILIB.;
      ;;
    *)
      echo You are not going MULTILIB.;
      ;;
  esac
fi


## detect efi and replace lilo with a script that works
if [ -d /boot/efi/EFI/boot/ ]; then
  cp /sbin/lilo /sbin/lilo.orig
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/EFI/lilo -P /sbin/
fi

## no need to run this on efi
if [ -e /etc/lilo.conf ]; then
  ## configure lilo
  sed -i 's/^#compact/lba32\
  compact/g' /etc/lilo.conf

  ## set to utf8 and pass acpi kernel params
  ## these fix brightness key issues on some comps
  ## and have no negative effects on others (in my testing at least)
  sed -i 's/^append=" vt.default_utf8=[0-9]"/append=" vt.default_utf8=1 acpi_osi=linux acpi_backlight=vendor"/g' /etc/lilo.conf
  
  sed -i 's/^timeout = 50/timeout = 5/g' /etc/lilo.conf
  sed -i 's/^timeout = 1200/timeout = 5/g' /etc/lilo.conf
fi

lilo

## change to utf-8 encoding
sed -i 's/^export LANG=en_US/#export LANG=en_US/g' /etc/profile.d/lang.sh
sed -i 's/^#export LANG=en_US.UTF-8/export LANG=en_US.UTF-8/g' /etc/profile.d/lang.sh

if [ "$CURRENT" = true ]; then
  ## adjust slackpkg blacklist
  sed -i 's/^aaa_elflibs/#aaa_elflibs/g' /etc/slackpkg/blacklist
fi

sed -i 's/#\[0-9]+_SBo/\
\[0-9]+_SBo\
sbopkg/g' /etc/slackpkg/blacklist

if [ "$CURRENT" = true ]; then
  ### undo stable mirrors
  sed -i \
  "s_^http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_# http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
  sed -i \
  "s_^http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_# http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
  ### osuosl mirrors are stable and fast (they are used for the changelogs), choose mirrorbrain if you are far from oregon
  sed -i \
  "s_^# http://ftp.osuosl.org/.2/slackware/slackware-current/_http://ftp.osuosl.org/.2/slackware/slackware-current/_g" /etc/slackpkg/mirrors
  sed -i \
  "s_^# http://ftp.osuosl.org/.2/slackware/slackware64-current/_http://ftp.osuosl.org/.2/slackware/slackware64-current/_g" /etc/slackpkg/mirrors
else
  ### undo current
  sed -i \
  "s_^http://ftp.osuosl.org/.2/slackware/slackware-current/_# http://ftp.osuosl.org/.2/slackware/slackware-current/_g" /etc/slackpkg/mirrors
  sed -i \
  "s_^http://ftp.osuosl.org/.2/slackware/slackware64-current/_# http://ftp.osuosl.org/.2/slackware/slackware64-current/_g" /etc/slackpkg/mirrors
  ### osuosl mirrors are stable and fast (they are used for the changelogs), choose mirrorbrain if you are far from oregon
  sed -i \
  "s_^# http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
  sed -i \
  "s_^# http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
fi


if [ -z "$( cat /etc/profile | grep 'export EDITOR' && cat /etc/profile | grep 'export VISUAL' )" ]; then
  echo >> /etc/profile
  echo "export EDITOR=vim" >> /etc/profile
  echo "export VISUAL=vim" >> /etc/profile
  echo >> /etc/profile
fi

if [ -z "$( cat /etc/profile | grep 'alias ls=' )" ]; then
  echo >> /etc/profile
  echo "alias ls='ls --color=auto'" >> /etc/profile
  echo >> /etc/profile
fi

if [ -z "$( cat /etc/profile | grep 'MAKEFLAGS' )" ]; then
  echo >> /etc/profile
  echo 'if (( $( nproc ) > 2 )); then' >> /etc/profile
  ## cores--
  echo '  export MAKEFLAGS="-j$( expr $( nproc ) - 1 )"' >> /etc/profile
  ## half the cores
  #echo '  export MAKEFLAGS="-j$( expr $( nproc ) / 2 )"' >> /etc/profile
  echo 'else' >> /etc/profile
  echo '  export MAKEFLAGS="-j1"' >> /etc/profile
  echo 'fi' >> /etc/profile
  echo >> /etc/profile
fi

## otherwise all our new stuff won't load until we log in again  ;^)
. /etc/profile


wget -N $BASHRC -P ~/
wget -N $BASHPR -P ~/
wget -N $VIMRC -P ~/
mkdir -p ~/.vim/colors/
wget -N $VIMCOLOR -P ~/.vim/colors/

wget -N $TOUCHPCONF -P /etc/X11/xorg.conf.d/
wget -N $INSCRPT -P /etc/

wget -N $TMUXCONF -P /etc/


## git config
git config --global user.name "$GITNAME"
git config --global user.email "$GITEMAIL"
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple
git config --global core.pager "less -r"

## install sbopkg & slackpkg+
wget -N $SBOPKGDL -P ~/
wget -N $SPPLUSDL -P ~/
upgradepkg --install-new ~/*.t?z
rm ~/*.t?z

## use SBo master git branch instead of a specific version
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sbo/90-SBo-master.repo \
  -P /etc/sbopkg/repos.d/

## use SBo-master as default ...
## but only comment out the old lines for an easy swap
if [ -z "$( cat /etc/sbopkg/sbopkg.conf | grep SBo-master )" ]; then
  sed -i "s@REPO_BRANCH=@#REPO_BRANCH=@g" /etc/sbopkg/sbopkg.conf
  sed -i "s@REPO_NAME=@#REPO_NAME=@g" /etc/sbopkg/sbopkg.conf
  echo "REPO_BRANCH=\${REPO_BRANCH:-master}" >> /etc/sbopkg/sbopkg.conf
  echo "REPO_NAME=\${REPO_NAME:-SBo-master}" >> /etc/sbopkg/sbopkg.conf
fi

## create sbopkg directories
mkdir -pv /var/lib/sbopkg/SBo-master/
mkdir -pv /var/lib/sbopkg/queues/
mkdir -pv /var/log/sbopkg/
mkdir -pv /var/cache/sbopkg/
mkdir -pv /tmp/SBo/
## reverse
#rm -rfv /var/lib/sbopkg/
#rm -rfv /var/log/sbopkg/
#rm -rfv /var/cache/sbopkg/
#rm -rfv /tmp/SBo/


## gkrellm theme
mkdir -p /usr/share/gkrellm2/themes/
wget -N https://github.com/ryanpcmcquen/themes/raw/master/egan-gkrellm.tar.gz -P ~/
tar xf ~/egan-gkrellm.tar.gz -C /usr/share/gkrellm2/themes/
rm ~/egan-gkrellm.tar.gz


## set slackpkg to non-interactive mode to run without prompting
set_slackpkg_to_auto

## to reset run with RESETSPPLUSCONF=y prepended
if [ ! -e /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP ] || [ "$RESETSPPLUSCONF" = y ]; then
  if [ "$RESETSPPLUSCONF" = y ]; then
    cp /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP /etc/slackpkg/BACKUP0-slackpkgplus.conf.old-BACKUP0
    cp /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP /etc/slackpkg/slackpkgplus.conf
  fi
  cp /etc/slackpkg/slackpkgplus.conf.new /etc/slackpkg/slackpkgplus.conf
  cp /etc/slackpkg/slackpkgplus.conf /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP
  sed -i 's@REPOPLUS=( slackpkgplus restricted alienbob slacky )@#REPOPLUS=( slackpkgplus restricted alienbob slacky )@g' /etc/slackpkg/slackpkgplus.conf
  sed -i "s@MIRRORPLUS\['slacky'\]@#MIRRORPLUS['slacky']@g" /etc/slackpkg/slackpkgplus.conf

  echo >> /etc/slackpkg/slackpkgplus.conf
  echo >> /etc/slackpkg/slackpkgplus.conf
  echo "#PKGS_PRIORITY=( multilib:.* ktown:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#PKGS_PRIORITY=( ktown:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  if [ "$MULTILIB" != true ]; then
    if [ "$CURRENT" = true ]; then
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
    else
      echo "#PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
    fi
    echo "#PKGS_PRIORITY=( multilib:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  fi

  if [ "$MULTILIB" = true ] && [ "$( uname -m )" = "x86_64" ]; then
    if [ "$CURRENT" = true ]; then
      sed -i "s@#MIRRORPLUS\['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/current/@MIRRORPLUS['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/current/@g" \
      /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "PKGS_PRIORITY=( multilib:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
    else
      sed -i "s@#MIRRORPLUS\['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/${SLACKSTAVER}/@MIRRORPLUS['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/${SLACKSTAVER}/@g" \
      /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "PKGS_PRIORITY=( multilib:.* )" >> /etc/slackpkg/slackpkgplus.conf
    fi
    echo >> /etc/slackpkg/slackpkgplus.conf
    echo "#PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  fi

  echo >> /etc/slackpkg/slackpkgplus.conf
  echo "#PKGS_PRIORITY=( multilib:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#PKGS_PRIORITY=( multilib:.* ktown:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#PKGS_PRIORITY=( ktown:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
  echo >> /etc/slackpkg/slackpkgplus.conf
  echo "#REPOPLUS=( slackpkgplus msb restricted alienbob slacky )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#REPOPLUS=( slackpkgplus restricted alienbob slacky )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#REPOPLUS=( slackpkgplus msb restricted alienbob )" >> /etc/slackpkg/slackpkgplus.conf
  echo >> /etc/slackpkg/slackpkgplus.conf
  echo "REPOPLUS=( slackpkgplus restricted alienbob )" >> /etc/slackpkg/slackpkgplus.conf
  echo >> /etc/slackpkg/slackpkgplus.conf
  echo "#REPOPLUS=( slackpkgplus msb alienbob )" >> /etc/slackpkg/slackpkgplus.conf
  echo "#REPOPLUS=( slackpkgplus alienbob )" >> /etc/slackpkg/slackpkgplus.conf
  echo >> /etc/slackpkg/slackpkgplus.conf
  
  if [ "$( uname -m )" = "x86_64" ]; then
    echo >> /etc/slackpkg/slackpkgplus.conf
    echo "#MIRRORPLUS['msb']=http://slackware.org.uk/msb/${SLACKSTAVER}/${MSBVER}/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
    echo "#MIRRORPLUS['ktown']=http://taper.alienbase.nl/mirrors/alien-kde/current/latest/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
    if [ "$CURRENT" = true ]; then
      echo "MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
      echo "MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
    else
      echo "#MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
      echo "#MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
    fi
    echo >> /etc/slackpkg/slackpkgplus.conf
  else
    echo >> /etc/slackpkg/slackpkgplus.conf
    echo "#MIRRORPLUS['msb']=http://slackware.org.uk/msb/${SLACKSTAVER}/${MSBVER}/x86/" >> /etc/slackpkg/slackpkgplus.conf
    echo "#MIRRORPLUS['ktown']=http://taper.alienbase.nl/mirrors/alien-kde/current/latest/x86/" >> /etc/slackpkg/slackpkgplus.conf
    if [ "$CURRENT" = true ]; then
      echo "MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
      echo "MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
    else
      echo "#MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
      echo "#MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
    fi
    echo >> /etc/slackpkg/slackpkgplus.conf
  fi

fi


if [ "$MULTILIB" = true ] && [ "$( uname -m )" = "x86_64" ]; then
  slackpkg_full_upgrade
  slackpkg_update_only
  slackpkg install multilib
  set_slackpkg_to_auto
fi


if [ "$MISCELLANY" = true ]; then
  ## this prevents breakage if slackpkg gets updated
  slackpkg_full_upgrade

  ## set slackpkg to non-interactive mode to run without prompting
  ## we set again just in case someone overwrites configs
  set_slackpkg_to_auto
  slackpkg_update_only
  slackpkg install vlc chromium

  ## auto-update once a day to keep the doctor away
  wget -N \
    https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/daily-slackup \
    -P /etc/cron.daily/
  chmod 755 /etc/cron.daily/daily-slackup

  ## grab latest firefox developer edition
  curl https://raw.githubusercontent.com/ryanpcmcquen/ryanpc-slackbuilds/master/unofficial/fde/getFDE.sh | sh

  ## eric hameleers has updated multilib to include this package
  #  if [ "$( uname -m )" = "x86_64" ]; then
  #    wget -N http://mirrors.slackware.com/slackware/slackware-current/slackware/x/$LIBXSHM -P ~/
  #    upgradepkg --install-new ~/$LIBXSHM
  #    rm ~/$LIBXSHM
  #    slackpkg blacklist libxshmfence
  #  fi

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
fi


## check for sbopkg update,
## then sync the slackbuilds.org repo
sbopkg -B -u
sbopkg -B -r

###########
### dwm ###
###########

## sweet, sweet dwm
no_prompt_sbo_pkg_install dwm
no_prompt_sbo_pkg_install dmenu
no_prompt_sbo_pkg_install trayer-srg
no_prompt_sbo_pkg_install tinyterm

## my dwm tweaks
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/xinitrc.dwm \
  -P /etc/X11/xinit/
chmod 755 /etc/X11/xinit/xinitrc.dwm
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/dwm-autostart \
  -P /usr/local/etc/

## make tinyterm the default
ln -sfv /usr/bin/tinyterm /usr/local/bin/uxterm
ln -sfv /usr/bin/tinyterm /usr/local/bin/xterm
ln -sfv /usr/bin/tinyterm /usr/local/bin/Eterm

###########
### end ###
### dwm ###
###########


if [ "$MISCELLANY" = true ]; then
  no_prompt_sbo_pkg_install pysetuptools
  no_prompt_sbo_pkg_install pip
  pip install --upgrade asciinema

  no_prompt_sbo_pkg_install node

  ## hydrogen
  no_prompt_sbo_pkg_install scons
  no_prompt_sbo_pkg_install libtar
  no_prompt_sbo_pkg_install ladspa_sdk
  no_prompt_sbo_pkg_install liblrdf
  ## celt is broken
  #no_prompt_sbo_pkg_install celt
  no_prompt_sbo_pkg_install jack-audio-connection-kit
  no_prompt_sbo_pkg_install lash
  no_prompt_sbo_pkg_install hydrogen
  ##

  JACK=on no_prompt_sbo_pkg_install ssr

  no_prompt_sbo_pkg_install lua

  no_prompt_sbo_pkg_install luajit

  no_prompt_sbo_pkg_install bullet

  no_prompt_sbo_pkg_install libwebp

  no_prompt_sbo_pkg_install orc

  no_prompt_sbo_pkg_install gstreamer1

  no_prompt_sbo_pkg_install gst1-plugins-base

  ## e16, so tiny!
  no_prompt_sbo_pkg_install imlib2
  no_prompt_sbo_pkg_install e16
  no_prompt_sbo_pkg_install gmrun

  if [ -z "$( cat /usr/share/e16/config/bindings.cfg | grep gmrun )" ]; then
    echo "KeyDown A Esc  exec gmrun" >> /usr/share/e16/config/bindings.cfg
  fi

  no_prompt_sbo_pkg_install giblib

  no_prompt_sbo_pkg_install scrot

  no_prompt_sbo_pkg_install screenfetch

  ## this library is necessary for some games,
  ## doesn't hurt to have it  ; ^)
  no_prompt_sbo_pkg_install libtxc_dxtn

  no_prompt_sbo_pkg_install lame

  no_prompt_sbo_pkg_install x264

  no_prompt_sbo_pkg_install ffmpeg

  no_prompt_sbo_pkg_install OpenAL

  no_prompt_sbo_pkg_install SDL_gfx

  no_prompt_sbo_pkg_install SDL_sound

  if [ "$MULTILIB" = true ]; then
    COMPAT32=yes no_prompt_sbo_pkg_install apulse
  else
    no_prompt_sbo_pkg_install apulse
  fi

  ## wineing
  if [ "$MULTILIB" = true ] || [ "$ARCH" = "i486" ]; then
    no_prompt_sbo_pkg_install webcore-fonts    
    no_prompt_sbo_pkg_install fontforge   
    no_prompt_sbo_pkg_install cabextract
    no_prompt_sbo_pkg_install wine    
    no_prompt_sbo_pkg_install winetricks
  fi
  ##

  ## scribus
  ## cppunit breaks podofo on 32-bit
  #no_prompt_sbo_pkg_install cppunit
  no_prompt_sbo_pkg_install podofo
  no_prompt_sbo_pkg_install scribus
  ##

  ## inkscape
  no_prompt_sbo_pkg_install gts
  no_prompt_sbo_pkg_install graphviz
  no_prompt_sbo_pkg_install libwpg
  no_prompt_sbo_pkg_install numpy
  no_prompt_sbo_pkg_install BeautifulSoup
  no_prompt_sbo_pkg_install lxml
  no_prompt_sbo_pkg_install libsigc++
  no_prompt_sbo_pkg_install glibmm
  no_prompt_sbo_pkg_install cairomm
  no_prompt_sbo_pkg_install pangomm
  no_prompt_sbo_pkg_install atkmm
  no_prompt_sbo_pkg_install mm-common
  no_prompt_sbo_pkg_install gtkmm
  no_prompt_sbo_pkg_install gsl
  no_prompt_sbo_pkg_install inkscape
  ##

  no_prompt_sbo_pkg_install libreoffice

  no_prompt_sbo_pkg_install android-studio

  ## librecad
  no_prompt_sbo_pkg_install muParser
  no_prompt_sbo_pkg_install librecad
  ##

  ## these are for the image ultimator
  no_prompt_sbo_pkg_install jpegoptim
  no_prompt_sbo_pkg_install mozjpeg
  no_prompt_sbo_pkg_install optipng
  no_prompt_sbo_pkg_install gifsicle
  ## install the image ultimator now that we have the dependencies
  wget -N \
    https://raw.githubusercontent.com/ryanpcmcquen/image-ultimator/master/imgult -P ~/
  install -m755 ~/imgult /usr/local/bin/
  rm ~/imgult
  ##

  no_prompt_sbo_pkg_install murrine

  no_prompt_sbo_pkg_install murrine-themes

  ## because QtCurve looks amazing
  if [ -e /var/log/packages/kdelibs-* ]; then
    no_prompt_sbo_pkg_install QtCurve-KDE4
    no_prompt_sbo_pkg_install kde-gtk-config
  fi
  no_prompt_sbo_pkg_install QtCurve-Gtk2

  no_prompt_sbo_pkg_install p7zip

  no_prompt_sbo_pkg_install dmg2img

  no_prompt_sbo_pkg_install medit

  no_prompt_sbo_pkg_install libgnomecanvas

  no_prompt_sbo_pkg_install zenity

  no_prompt_sbo_pkg_install udevil

  no_prompt_sbo_pkg_install spacefm

  no_prompt_sbo_pkg_install mirage

  no_prompt_sbo_pkg_install copy

  if [ "$( uname -m )" = "x86_64" ]; then
    no_prompt_sbo_pkg_install spotify64
  else
    no_prompt_sbo_pkg_install spotify32
  fi

  no_prompt_sbo_pkg_install tiled-qt

  no_prompt_sbo_pkg_install google-webdesigner


  ## grab latest steam package
  if [ ! -e /var/log/packages/steamclient-* ]; then
    wget -r -np -A.tgz http://www.slackware.com/~alien/slackbuilds/steamclient/pkg/current/
    mv ~/www.slackware.com/\~alien/slackbuilds/steamclient/pkg/current/*.tgz ~/
    rm -rf ~/www.slackware.com/
    upgradepkg --install-new ~/steamclient-*.tgz
    if [ -z "$( cat /etc/slackpkg/blacklist | grep steamclient )" ]; then
      echo steamclient >> /etc/slackpkg/blacklist
    fi
    rm ~/steamclient-*.tgz
  fi

  curl $GETJAVA | sh

  ## numix stuff is dead sexy
  git clone https://github.com/numixproject/numix-icon-theme.git
  rm -rf /usr/share/icons/Numix/
  mv ./numix-icon-theme/Numix/ /usr/share/icons/
  rm -rf ./numix-icon-theme/

  git clone https://github.com/numixproject/numix-icon-theme-bevel.git
  rm -rf /usr/share/icons/Numix-Bevel/
  mv ./numix-icon-theme-bevel/Numix-Bevel/ /usr/share/icons/
  rm -rf ./numix-icon-theme-bevel/

  git clone https://github.com/numixproject/numix-icon-theme-circle.git
  rm -rf /usr/share/icons/Numix-Circle/
  mv ./numix-icon-theme-circle/Numix-Circle/ /usr/share/icons/
  rm -rf ./numix-icon-theme-circle/

  git clone https://github.com/numixproject/numix-icon-theme-shine.git
  rm -rf /usr/share/icons/Numix-Shine/
  mv ./numix-icon-theme-shine/Numix-Shine/ /usr/share/icons/
  rm -rf ./numix-icon-theme-shine/

  git clone https://github.com/numixproject/numix-icon-theme-utouch.git
  rm -rf /usr/share/icons/Numix-uTouch/
  mv ./numix-icon-theme-utouch/Numix-uTouch/ /usr/share/icons/
  rm -rf ./numix-icon-theme-utouch/

  git clone https://github.com/shimmerproject/Numix.git
  rm -rf /usr/share/themes/Numix/
  mv ./Numix/ /usr/share/themes/
  rm -rf ./Numix/

  wget -N \
    https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.colors -P /usr/share/apps/color-schemes/
  mv /usr/share/apps/color-schemes/Numix.colors /usr/share/apps/color-schemes/Numix-KDE.colors
  wget -N \
    https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.qtcurve -P /usr/share/apps/QtCurve/
  mv /usr/share/apps/QtCurve/Numix.qtcurve /usr/share/apps/QtCurve/Numix-KDE.qtcurve

  ## caledonia kde theme
  wget -N \
    http://sourceforge.net/projects/caledonia/files/Caledonia%20%28Plasma-KDE%20Theme%29/$CALPLAS -P ~/
  tar xf ~/$CALPLAS -C /usr/share/apps/desktoptheme/
  rm ~/$CALPLAS

  ## caledonia color scheme
  wget -N http://sourceforge.net/projects/caledonia/files/Caledonia%20Color%20Scheme/Caledonia.colors \
    -P /usr/share/apps/color-schemes/

  ## get caledonia wallpapers, who doesn't like nice wallpapers?
  wget -N \
    http://sourceforge.net/projects/caledonia/files/Caledonia%20Official%20Wallpapers/$CALWALL -P ~/
  tar xf ~/$CALWALL
  cp -r ~/Caledonia_Official_Wallpaper_Collection/* /usr/share/wallpapers/
  rm -rf ~/Caledonia_Official_Wallpaper_Collection/
  rm ~/$CALWALL

  ## a few numix wallpapers also
  wget -N \
    http://fc03.deviantart.net/fs71/f/2013/305/3/6/numix___halloween___wallpaper_by_satya164-d6skv0g.zip -P ~/
  wget -N \
    http://fc00.deviantart.net/fs70/f/2013/249/7/6/numix___fragmented_space_by_me4oslav-d6l8ihd.zip -P ~/
  wget -N \
    http://fc09.deviantart.net/fs70/f/2013/224/b/6/numix___name_of_the_doctor___wallpaper_by_satya164-d6hvzh7.zip -P ~/
  unzip numix___halloween___wallpaper_by_satya164-d6skv0g.zip
  unzip numix___fragmented_space_by_me4oslav-d6l8ihd.zip
  unzip numix___name_of_the_doctor___wallpaper_by_satya164-d6hvzh7.zip
  rm numix___halloween___wallpaper_by_satya164-d6skv0g.zip
  rm numix___fragmented_space_by_me4oslav-d6l8ihd.zip
  rm numix___name_of_the_doctor___wallpaper_by_satya164-d6hvzh7.zip

  cp ~/*.png /usr/share/wallpapers/
  #cp ~/*.png /usr/share/backgrounds/
  cp ~/*.jpg /usr/share/wallpapers/
  #cp ~/*.jpg /usr/share/backgrounds/
  rm ~/*.jpg
  rm ~/*.png
else
  echo "You have gone VANILLA."
fi


## used to be beginning of SCRIPTS

if [ "$CURRENT" = true ]; then
  wget -N $GETEXTRACUR -P ~/
  wget -N $GETSOURCECUR -P ~/
else
  wget -N $GETEXTRASTA -P ~/
  wget -N $GETSOURCESTA -P ~/
fi

wget -N $GETJAVA -P ~/

## bumblebee/nvidia scripts
if [ ! -z "$( lspci | grep NVIDIA )" ]; then
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/crazybee.sh -P ~/
fi

## auto generic-kernel script
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/switchToGenericKernel.sh -P ~/

## slackbook.org
git clone https://github.com/ryanpcmcquen/slackbook.org.git

## my slackbuilds
git clone https://github.com/ryanpcmcquen/ryanpc-slackbuilds.git

## enlightenment!
git clone https://github.com/ryanpcmcquen/slackENLIGHTENMENT.git

## script to install latest firefox developer edition
wget -N https://raw.githubusercontent.com/ryanpcmcquen/ryanpc-slackbuilds/master/unofficial/fde/getFDE.sh -P ~/

## used to be end of SCRIPTS


if [ "$WICD" = true ]; then
  slackpkg_update_only
  slackpkg install wicd
  chmod -x /etc/rc.d/rc.networkmanager
  sed -i 's/^\([^#]\)/#\1/g' /etc/rc.d/rc.inet1.conf
fi

## let there be sound!
/etc/rc.d/rc.alsa
if [ ! -z "$( aplay -l | grep Analog | grep 'card 1' )" ]; then
  amixer set -c 1 Master 0% unmute
  amixer set -c 1 Master 70% unmute
  amixer set -c 1 PCM 0% unmute
  amixer set -c 1 PCM 80% unmute
  amixer set -c 1 Mic 0% unmute
  amixer set -c 1 Mic 50% unmute
  amixer set -c 1 Capture 0% cap
  amixer set -c 1 Capture 50% cap
else
  amixer set Master 0% unmute
  amixer set Master 70% unmute
  amixer set PCM 0% unmute
  amixer set PCM 80% unmute
  amixer set Mic 0% unmute
  amixer set Mic 50% unmute
  amixer set Capture 0% cap
  amixer set Capture 50% cap
fi

alsactl store


## set slackpkg back to normal
set_slackpkg_to_manual


## create an info file
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "========================================" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "CONFIG-O-MATIC $CONFIGOMATICVERSION" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "BLANK = false" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION

echo "CURRENT = $CURRENT" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "WICD = $WICD" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "MISCELLANY = $MISCELLANY" >> ~/.config-o-matic_$CONFIGOMATICVERSION
if [ "$( uname -m )" = "x86_64" ]; then
  echo "MULTILIB = $MULTILIB" >> ~/.config-o-matic_$CONFIGOMATICVERSION
fi

echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "========================================" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION

rm ~/SlackwareStableVersion

## thanks!
echo
echo
echo "************************************"
echo "********** CONFIG-O-MATIC **********"
echo "************************************"
echo
echo "Your system is now set to UTF-8."
echo "(e.g. You should use uxterm, instead of xterm)."
echo "Thank you for using config-o-matic!"
echo
echo "You should now run 'adduser', if you have not."
echo "Then you should run the $ user script."
echo




