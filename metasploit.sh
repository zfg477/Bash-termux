#!/data/data/com.termux/files/usr/bin/bash

cwd=$(pwd)
name=$(basename "$0")
export msfinst="$cwd/$name"

msfpath='/mnt/media_rw/9512b14c-1c56-4048-b872-9a51e7c9c2c0/linux/software/'
if [ -d "$msfpath/metasploit-framework" ]; then
	echo "metasploit is installed"
	exit 1
fi
apt update
apt install -y autoconf bison clang coreutils curl findutils git apr apr-util libffi-dev libgmp-dev libpcap-dev postgresql-dev readline-dev libsqlite-dev openssl-dev libtool libxml2-dev libxslt-dev ncurses-dev pkg-config wget make ruby-dev libgrpc-dev termux-tools ncurses-utils ncurses unzip zip tar postgresql termux-elf-cleaner

cd $msfpath
#curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz
#tar -xf $msfpath/$msfvar.tar.gz
git clone https://github.com/rapid7/metasploit-framework.git
#mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework
echo "[ Installing Ruby gems ]"
gem install bundler
bundle install -j5
echo "Gems installed"


echo "[Creating database]"

cd $msfpath/metasploit-framework/config
echo 'production:' >database.yml
echo 'adapter: postgresql'>>database.yml
echo 'database: msf_database'>>database.yml
echo 'username: msf'>>database.yml
echo 'password:'>>database.yml
echo 'host: 127.0.0.1'>>database.yml
echo 'port: 5432'>>database.yml
echo 'pool: 75'>>database.yml
echo 'timeout: 5'>>database.yml

#curl -LO https://Auxilus.github.io/database.yml

mkdir -p $PREFIX/var/lib/postgresql
initdb $PREFIX/var/lib/postgresql

pg_ctl -D $PREFIX/var/lib/postgresql start
createuser msf
createdb msf_database



echo "[ Creating run scripts ]"
echo "msfconsole"
echo '*'$PREFIX'/bin/msfconsole'
echo '#!/bin/bash'> $PREFIX/bin/msfconsole
echo 'pg_ctl -D $PREFIX/var/lib/postgresql restart>/dev/null 2>&1'>> $PREFIX/bin/msfconsole
echo $msfpath'/metasploit-framework/msfconsole $*' >> $prefix/bin/msfconsole
chmod +x $prefix/bin/msfconsole

echo 'msfvenom'
echo '*'$PREFIX'/bin/msfvenom'
echo '#!/bin/bash'> $PREFIX/bin/msfvenom
echo $msfpath'/metasploit-framework/msfvenom $*' >> $PREFIX/bin/msfvenom
chmod +x $PREFIX/bin/msfvenom

#rm $msfpath/$msfvar.tar.gz

echo "you can directly use msfvenom or msfconsole rather than ./msfvenom or ./msfconsole as they are symlinked to $PREFIX/bin"


