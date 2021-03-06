modified=$(git status -s)

if [ "$modified" != "" ] ; then
  if [ "$1" != "test" ] ; then
    echo "Error, directory has modified files."
    exit 1
  fi
fi

uncrustify --no-backup --replace -l OC+ -c uncrustify.cfg `find src \( -name "*.m" -o -name "*.h" \)`
uncrustify --no-backup --replace -l OC+ -c uncrustify.cfg `find mac \( -name "*.m" -o -name "*.h" \)`
uncrustify --no-backup --replace -l OC+ -c uncrustify.cfg `find ios \( -name "*.m" -o -name "*.h" \)`
