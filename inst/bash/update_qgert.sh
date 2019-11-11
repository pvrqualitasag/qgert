#!/bin/bash
#' ---
#' title: Update R Package qgert on zws Servers
#' date:  2019-10-29 10:08:00
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' R-packages are installed locally on each server. Hence, updates of the packages must be deployed to
#' every server. This script loops over a list of servers and runs an update statement to get the
#' latest version of the R package `qgert`.
#'
#' ## Description
#' The update is done via a singularity exec statement on the running instance on every server. This
#' exec statement takes as argument a shell command which is executed on the singularity instance.
#'
#' ## Bash Settings
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
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -r <repo_reference> -s <server_name>"
  $ECHO "  where -s <server_name>     --  optional, run package update on single server"
  $ECHO "        -r <repo_reference>  --  optional, update to a branch reference"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### Update For a Given Server
#' The following function runs the package update on a
#' specified server.
#+ update-pkg-fun
update_pkg () {
  local l_SERVER=$1
  log_msg 'update_pkg' "Running update on $l_SERVER"
  if [ "$REFERENCE" != "" ]
  then
    $ECHO "singularity exec instance://sizws R -e 'devtools::install_github(\"pvrqualitasag/qgert\", ref = \"${REFERENCE}\")'" | ssh zws@$l_SERVER
  else
    $ECHO "singularity exec instance://sizws R -e 'devtools::install_github(\"pvrqualitasag/qgert\")'" | ssh zws@$l_SERVER
  fi
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
SERVERS=(beverin castor niesen)
SERVERNAME=""
REFERENCE=""
while getopts ":r:s:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    r)
      REFERENCE=$OPTARG
      ;;
    s)
      SERVERNAME=$OPTARG
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


#' ## Run Updates
#' Decide whether to run the update on one server or on all servers on the list
if [ "$SERVERNAME" != "" ]
then
  update_pkg $SERVERNAME
else
  for s in ${SERVERS[@]}
  do
    update_pkg $s
    sleep 2
  done
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

