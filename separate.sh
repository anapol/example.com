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

function rename_to_upstream () {
  SUBDIR="$1"
  if [ -d "$EZPCHECKOUT"/"$SUBDIR" -a ! -L "$EZPCHECKOUT"/"$SUBDIR" ]; then
   echo Moving "$EZPCHECKOUT"/"$SUBDIR" to "$EZPCHECKOUT"/"$SUBDIR".upstream
   mv "$EZPCHECKOUT"/"$SUBDIR" "$EZPCHECKOUT"/"$SUBDIR".upstream
  fi
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


#echo "Symlinking everything to the ezpublish-legacy checkout..."

#REL_DEST_TO_EZPCHECKOUT=$(relative_path $EZPCHECKOUT $DEST)
#for F in "$EZPCHECKOUT"/*; do
# symlink "$REL_DEST_TO_EZPCHECKOUT"/"$(basename $F)" "$DEST"/"$(basename $F)"
#done


echo "### Relinking extension(s)"
rename_to_upstream extension
symlink "$(relative_path $AAEXTENSIONDIR $EZPCHECKOUT)" "$EZPCHECKOUT"/extension

for extension in ezformtoken ezjscore ezoe; do
 symlink "$(relative_path $EZPCHECKOUT $AAEXTENSIONDIR)"/extension.upstream/$extension "$EZPCHECKOUT"/extension/$extension
done


echo "### Relinking var"
rename_to_upstream "var"
symlink "$(relative_path $AAVARDIR $DEST)" "$EZPCHECKOUT"/var


echo "### Relinking share locale & translations"
rename_to_upstream "share/locale"
symlink "$(relative_path $AAI18NDIR/locale $EZPCHECKOUT/share/)" "$EZPCHECKOUT"/share/locale

rename_to_upstream "share/translations"
symlink "$(relative_path $AAI18NDIR/translations $EZPCHECKOUT/share/)" "$EZPCHECKOUT"/share/translations


echo "### Relinking settings"
rename_to_upstream "settings/siteaccess"
symlink "$(relative_path $AASETTINGSDIR/siteaccess $EZPCHECKOUT/settings/)" "$EZPCHECKOUT"/settings/siteaccess

rename_to_upstream settings/override
symlink "$(relative_path $AASETTINGSDIR/override $EZPCHECKOUT/settings/)" "$EZPCHECKOUT"/settings/override


echo "Done."

