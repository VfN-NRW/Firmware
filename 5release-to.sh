if [[ "$1" == "" ]] ; then
  echo missing arg
  ls -1  /var/www/firmware2/
  exit 1
fi

rm /var/www/firmware2/$1/*
cp -r images/* /var/www/firmware2/$1/ || exit 1
cp build.txt /var/www/firmware2/$1/build || exit 1
