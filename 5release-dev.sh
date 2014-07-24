rm /var/www/firmware2/dev/*
cp -r images/* /var/www/firmware2/dev/ || exit 1
cp build.txt /var/www/firmware2/dev/build || exit 1
