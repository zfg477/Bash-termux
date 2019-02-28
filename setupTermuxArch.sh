#!/data/data/com.termux/files/usr/bin/bash
folder=$(pwd)"/Arch"
cur=`pwd`
tarball="arch-linux.tar.gz"
tar_location=$(readlink -f $0|rev|cut -d "/" -f2-|rev)
tar_location=$tar_location'/'$tarball

#echo $tar_location
#echo $tarball
#exit


if [ -d "$folder" ]; then
	first=1
fi

if [ "$first" != 1 ];then
echo "skipping downloading"
	if [ ! -f $tar_location ]; then
		echo "downloading Arch-image"
		case `dpkg --print-architecture` in
		aarch64)	archurl="http://au.mirror.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz" ;;
	arm)
		archurl=http://au.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz ;;
		amd64)
			archurl="amd64" ;
echo "unknown architecture"; exit 1;;
		i*86)
		archurl="i386";
echo "unknown architecture"; exit 1;;
		*)
	echo "unknown architecture"; exit 1 ;;
	esac
		wget $archurl -O $tar_location
	fi
mkdir -p "$folder"
cd "$folder"
echo "decompressing arch image"
tar xf $tar_location > /dev/null 2>&1
mkdir -p binds
	echo "fixing nameserver, otherwise it can't connect to the internet"
echo "nameservers 8.8.8.8" > etc/resolvconf.conf
fi

	
cd "$cur"


bin=init-arch
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
echo "You can now launch Arch with the ./${bin} script"
