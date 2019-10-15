#!/bin/bash
#' ---
#' title: Spin Bash Script to Rmd
#' date:  2019-10-15 13:11:24
#' author: Peter von Rohr
#' ---
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #  



#' ## Functions
#' In this section user-defined functions that are specific for this script are 
#' defined in this section.
#'
#' @title: Show usage message
#' @param: message that is shown
#+ usg-msg, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -s <script_path> -o <out_file>"
  $ECHO "  where -s <script_path>  --  path to input script"
  $ECHO "        -o <out_file>     --  name of output file"
  $ECHO ""
  exit 1
}

#' produce a start message
#+ start-msg, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' produce an end message
#+ end-msg, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' functions related to logging
#+ log-msg, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
SCRIPTPATH=""
OUTFILE=""
while getopts ":s:o:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    s)
      if test -f $OPTARG; then
        SCRIPTPATH=$OPTARG
      else
        usage "$OPTARG isn't a regular file"
      fi
      ;;
    o)
      OUTFILE=$OPTARG
      ;;
    c)
      c_example="c_example_value"
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

#' ## Checks for Command Line Arguments 
#' The following statements are used to check whether required arguments 
#' have been assigned with a non-empty value
#+ argument-test, eval=FALSE
if test "$SCRIPTPATH" == ""; then
  usage "-s <script_path> not defined"
fi



#' ## Call the spin function in R
if [ "$OUTFILE" == "" ] 
then
  R -e "if (!'qgert' %in% installed.packages()) devtools::install_github('pvrqualitasag/qgert', upgrade = 'always');qgert::spin_sh(ps_sh_hair = '$SCRIPTPATH')" --no-save
else
  R -e "if (!'qgert' %in% installed.packages()) devtools::install_github('pvrqualitasag/qgert', upgrade = 'always');qgert::spin_sh(ps_sh_hair = '$SCRIPTPATH', ps_out_rmd = '$OUTFILE')" --no-save
fi




#' End of Script
#+ end-msg, eval=FALSE
end_msg

