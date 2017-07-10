################################################################################
# Gets the full path to a relative path
#
# arg1: The path to be converted into absolute
# return: The full path

function fullPath {
  TARGET_FILE=$1

  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`

  # Compute the canonicalized name by finding the physical path 
  # for the directory we're in and appending the target file.
  PHYS_DIR=`pwd -P`
  RESULT=$PHYS_DIR/$TARGET_FILE
  RESULT=${RESULT%/.}
  echo $RESULT
}

BASE_DIR=$(dirname $(fullPath $0))
zsh $BASE_DIR/install.sh
