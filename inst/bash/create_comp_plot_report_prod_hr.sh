#!/bin/bash
#' ---
#' title: Create Comparison Plot Report
#' date:  2020-09-22 17:42:02
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' This shell script is a wrapper to the R-package `qgert` which creates the comparison
#' plot reports. There is a separate shell script for every trait-group. The trait
#' group is determined by the variable `TRAIT` defined below.
#'
#' ## Description
#' The wrapper sets a number of variables that define the input parameters for report
#' creator function inside of the R-package `qgert`. The R-function call is done via
#' Rscript -e which takes a string that contains the function call.
#'
#' ## Details
#' This wrapper is a special case for the trait group 'prod' which is only used for
#' the breed 'hr'. Furthermore unused options such as -u to update the package are
#' removed. Package updates should be done using the separate update_qgert.sh script.
#' The option of directly adding directories with the plots for the current and the
#' previous evaluation are added.
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
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #


#' ### Trait
#' The trait abbreviation used in this comparison plot report
#+ trait-abbrev
TRAIT=prod


#' ## Functions
#' In this section user-defined functions that are specific for this script are
#' defined in this section.
#'
#' * title: Show usage message
#' * param: message that is shown
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -c <current_evaluation_label> -p <previous_evaluation_label>"
  $ECHO "  where -c <current_evaluation_label>   --  label of current evaluation, given by %YY%mm of publication date"
  $ECHO "        -p <previous_evaluation_label>  --  label of previous evaluation"
  $ECHO "        -d <current_plotting_root>      --  root directory of current comparison plots"
  $ECHO "        -q <previous_plotting_root>     --  root directory of previous comparison plots"
  $ECHO ""
  exit 1
}

#' produce a start message
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' produce an end message
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' functions related to logging
#+ log-msg-fun, eval=FALSE
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
CURGE=""
PREVGE=""
CURPLOTROOT=""
PREVPLOTROOT=""
BREED='hr'
while getopts ":c:d:p:q:h" FLAG; do
  case $FLAG in
    h) # produce usage message
      usage "Help message for $SCRIPT"
      ;;
    c) # specify label of current GE
      CURGE=$OPTARG
      ;;
    d)
      CURPLOTROOT=$OPTARG
      ;;
    p) # specify label of previous GE
      PREVGE=$OPTARG
      ;;
    q)
      PREVPLOTROOT=$OPTARG
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
if test "$CURGE" == ""; then
  usage "-c <current_ge_label> not defined"
fi

if test "$PREVGE" == ""; then
  usage "-p <previous_ge_label> not defined"
fi


#' ## Creation of comparison plot reports
#' This is the beginning of the main part of the creation of the comparison plot reports.
#' After setting directory variables, the parameter file of the current evaluation run
#' is sourced to get all variables from the input parameters.
#+ dir-settings
EVAL_DIR=$(dirname $SCRIPT_DIR)
PROG_DIR=$EVAL_DIR/prog
PAR_DIR=$EVAL_DIR/par
source $PAR_DIR/par.par
log_msg $SCRIPT 'Basic directories and source parameters set'
log_msg $SCRIPT "EVAL_DIR=$EVAL_DIR"
log_msg $SCRIPT "PROG_DIR=$PROG_DIR"
log_msg $SCRIPT "PAR_DIR=$PAR_DIR"

#' The current working directory is changed to the evaluation directory
#+ cd-eval-dir
cd $EVAL_DIR

#' ## Set default values for two plot root directories
#' If plot root directories were not specified, they are set to defaults
#+ set-plot-root-default
if [ "$CURPLOTROOT" == "" ]
then
  CURPLOTROOT=/qualstorzws01/data_zws/eringer/work
fi
if [ "$PREVPLOTROOT" == "" ]
then
  PREVPLOTROOT=/qualstorzws01/data_archiv/zws/eringer/$PREVGE/work
fi


#' ## Report Creation
#' The report for the specified trait is created.
#+ create-report
Rscript -e "qgert::create_ge_compare_plot_report_${TRAIT}(pn_cur_ge_label=${CURGE}, pn_prev_ge_label = ${PREVGE}, ps_cur_plot_root = '${CURPLOTROOT}', ps_prev_plot_root = '${PREVPLOTROOT}', ps_breed='${BREED}')"


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg
