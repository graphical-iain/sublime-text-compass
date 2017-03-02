#!/bin/sh
IFS=`printf '\n+'`; IFS=${IFS%+}
FILE_PATH=$1;
PROJECT_PATH=${2-/};
COMPASS=`which compass`;

if [ -z "$COMPASS" ]; then
  echo "[ERROR] compass not found. Make sure it exists in your PATH.";
  exit;
fi

if [ `find "$FILE_PATH" -maxdepth 1 -name config.rb` ]; then
  $COMPASS compile "$FILE_PATH" --boring;
  FOUND=1;
fi;

while [ "$FILE_PATH" != "$PROJECT_PATH" ];
  do FILE_PATH=`dirname "$FILE_PATH"`;

  if [ `find "$FILE_PATH" -maxdepth 1 -name config.rb` ]; then

    # Check if there's an additional compile path and compile
    while IFS= read -r var
    do
      ADD_FILE_PATH=`expr "$var" : 'add_compile_path'`;
      if (($ADD_FILE_PATH>"0")); then
        # strip out declaration
        ADD_FILE_PATH=${var#*=};
        # strip out begining quote
        ADD_FILE_PATH=${ADD_FILE_PATH#*[\"]};
        # strip out ending quote
        ADD_FILE_PATH=${ADD_FILE_PATH%*[\"]};
        # prepend the file_path
        ADD_FILE_PATH="$FILE_PATH/$ADD_FILE_PATH/";
        for i in $ADD_FILE_PATH
        do
          if [ `find "$i" -maxdepth 1 -name config.rb` ]; then
            $COMPASS compile "$i" --boring;
          fi;
        done
      fi;
    done < "$FILE_PATH/config.rb"

    $COMPASS compile "$FILE_PATH" --boring;
    FOUND=1;
    break;
  fi;
done

if [ -z "$FOUND" ]; then
  echo "[ERROR] Build did not run because config.rb cannot be found.";
fi
