#!/bin/bash

#
# Creates a symlinked splitted copy of a classic ezpublish git checkout
# for simple updates and change tracking...
#
# Usage: separate.sh ezpublish-legacy_checkout_dir deployment_dir aaextension_dir aasettings_dir aai18n_dir aavar_dir
#
# ./separate.sh ./ezpublish-legacy/ ./webroot ./extension/ ./settings/ ./ezpublish-i18n/ ../var


function relative_path() {
  if [ -z $2 ]; then
    _result=$(perl -MFile::Spec -e 'print File::Spec->abs2rel(@ARGV)' "$1")
  else
    _result=$(perl -MFile::Spec -e 'print File::Spec->abs2rel(@ARGV)' "$1" "$2")
  fi
  echo $_result
}
function symlink () {
  if [ -e "$2" ]; then
    echo "NOT linking $1 -> $2, file exists..."
    return 1
  fi
  echo Linking "$1" "->" "$2"
  ln -s "$1" "$2"
}

EZPCHECKOUT=$(relative_path $1)
DEST=$(relative_path $2)

AAEXTENSIONDIR=$(relative_path $3)
AASETTINGSDIR=$(relative_path $4)
AAI18NDIR=$(relative_path $5)
AAVARDIR=$(relative_path $6)

if [ -z $6 ]; then
 echo "Usage: $0 ezpublish-legacy_checkout_dir deployment_dir aaextension_dir aasettings_dir aai18n_dir aavar_dir"
 exit 1
fi


echo "Creating a deployable copy at $DEST"


echo "Symlinking everything to the ezpublish-legacy checkout..."

REL_DEST_TO_EZPCHECKOUT=$(relative_path $EZPCHECKOUT $DEST)
for F in "$EZPCHECKOUT"/*; do
 symlink "$REL_DEST_TO_EZPCHECKOUT"/"$(basename $F)" "$DEST"/"$(basename $F)"
done


echo "### Relinking extensions"
rm "$DEST"/extension
symlink "$(relative_path $AAEXTENSIONDIR $DEST)" "$DEST"/extension

for extension in ezformtoken ezjscore ezoe; do
 symlink "$(relative_path $EZPCHECKOUT $AAEXTENSIONDIR)"/extension/$extension "$DEST"/extension/$extension
done


echo "### Relinking var"
rm "$DEST"/var
symlink "$(relative_path $AAVARDIR $DEST)" "$DEST"/var


echo "### Relinking share"
rm "$DEST"/share
mkdir "$DEST"/share

REL_DEST_TO_EZPCHECKOUT=$(relative_path $EZPCHECKOUT $DEST/share)
for F in "$EZPCHECKOUT"/share/*; do
 symlink "$REL_DEST_TO_EZPCHECKOUT"/share/"$(basename $F)" "$DEST"/share/"$(basename $F)"
done

rm "$DEST"/share/locale
symlink "$(relative_path $AAI18NDIR/locale $DEST/share/)" "$DEST"/share/locale

rm "$DEST"/share/translations
symlink "$(relative_path $AAI18NDIR/translations $DEST/share/)" "$DEST"/share/translations


echo "### Relinking settings"
rm "$DEST"/settings
mkdir "$DEST"/settings

REL_DEST_TO_EZPCHECKOUT=$(relative_path $EZPCHECKOUT $DEST/settings)
for F in "$EZPCHECKOUT"/settings/*; do
 symlink "$REL_DEST_TO_EZPCHECKOUT"/settings/"$(basename $F)" "$DEST"/settings/"$(basename $F)"
done

rm "$DEST"/settings/siteaccess
symlink "$(relative_path $AASETTINGSDIR/siteaccess $DEST/settings/)" "$DEST"/settings/siteaccess

rm "$DEST"/settings/override
symlink "$(relative_path $AASETTINGSDIR/override $DEST/settings/)" "$DEST"/settings/override



# autoload.php uses __DIR__./var/ reference, which isn't resolved to the relinked var dir...
echo "### Relinking autoload.php"
rm "$DEST"/autoload.php
cp $EZPCHECKOUT/autoload.php "$DEST"/autoload.php

echo "Done."

