for image in images/*; do 
  echo signing $image
  ./tools/bin/ecdsasign $image < ../nightly.key > $image.sig
done