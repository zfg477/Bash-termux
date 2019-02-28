#!/data/data/com.termux/files/usr/bin/bash
folder=$(pwd)"/ubuntu-bionic"
cur=`pwd`
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="ubuntu18.04.tar.gz"
tar_location=$(readlink -f $0|rev|cut -d "/" -f2-|rev)
tar_location=$tar_location'/'$tarball

if [ "$first" != 1 ];then
	if [ ! -f $tar_location ]; then
		echo "downloading ubuntu-image"
		case `dpkg --print-architecture` in
		aarch64)
			archurl="arm64" ;;
		arm)
			archurl="armhf" ;;
		amd64)
			archurl="amd64" ;;
		i*86)
			archurl="i386" ;;
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "https://partner-images.canonical.com/core/bionic/current/ubuntu-bionic-core-cloudimg-${archurl}-root.tar.gz" -O $tar_location
	fi
mkdir -p "$folder"
	cd "$folder"
	echo "decompressing ubuntu image"
tar xf $tar_location > /dev/null 2>&1

fi


mkdir -p binds
	echo "fixing nameserver, otherwise it can't connect to the internet"
	echo "nameserver 1.1.1.1" > etc/resolv.conf
	cd "$cur"


bin=init-ubuntu
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A ${folder}/binds/)" ]; then
    for f in ${folder}/binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "You can now launch Ubuntu with the ./${bin} script"
n=init-ubuntu
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is i