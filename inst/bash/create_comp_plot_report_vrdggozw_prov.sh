#!/bin/bash
###
###
###
###   Purpose:   Creation of comparison plot report for vrdggozw
###   started:   2019-07-08 10:48:12 (pvr)
###
### ###################################################################### ###

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails

# ======================================== # ======================================= #
# global constants                         #                                         #
# ---------------------------------------- # --------------------------------------- #
# prog paths                               #                                         #
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
# ---------------------------------------- # --------------------------------------- #
# directories                              #                                         #
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #
# ---------------------------------------- # --------------------------------------- #
# files                                    #                                         #
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) # define script directory   #
# ---------------------------------------- # --------------------------------------- #
# trait                                    #                                         #
TRAIT=vrdggozw_prov                        # Trait abbreviation                      #
# ======================================== # ======================================= #



### # ====================================================================== #
### # functions
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -c <current_ge_label> -p <previous_ge_label> -g <previous_gs_label> -u (optional, if package update is needed)"
  $ECHO "  where -c <current_ge_label> -- label of current genetic evaluation"
  $ECHO "        -p <previous_ge_label> -- label of previous genetic evaluation"
  $ECHO "        -g <previous_gs_label> -- label of previous bi-weekly gs-run level"
  $ECHO "        -u (optional, if package update is needed)"
  $ECHO ""
  exit 1
}

### # produce a start message
start_msg () {
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}

### # produce an end message
end_msg () {
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}


### # ====================================================================== #
### # Main part of the script starts here ...
start_msg

### # ====================================================================== #
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
CURGE=""
PREVGE=""
PACKAGEUPDATE=""
PREVGS=""
while getopts ":c:p:g:uh" FLAG; do
  case $FLAG in
    h) # produce usage message
      usage "Help message for $SCRIPT"
      ;;
    c) # specify label of current GE
      CURGE=$OPTARG
      ;;
    p) # specify label of previous GE
      PREVGE=$OPTARG
      ;;
    g) # previous gs-run label
      PREVGS=$OPTARG
      ;;
    u) # specify whether update of package zwsroutine is needed
      PACKAGEUPDATE=TRUE
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

# Check whether required arguments have been defined
if test "$CURGE" == ""; then
  usage "-c <current_ge_label> not defined"
fi

if test "$PREVGE" == ""; then
  usage "-p <previous_ge_label> not defined"
fi



# Set basic directories and source parameters
#============================================
EVAL_DIR=$(dirname $SCRIPT_DIR)
PROG_DIR=$EVAL_DIR/prog
PAR_DIR=$EVAL_DIR/par
#source $PAR_DIR/par.par
log_msg $SCRIPT 'Basic directories and source parameters set'
log_msg $SCRIPT "EVAL_DIR=$EVAL_DIR"
log_msg $SCRIPT "PROG_DIR=$PROG_DIR"
log_msg $SCRIPT "PAR_DIR=$PAR_DIR"

cd $EVAL_DIR

# Check whether devtools is installed
# is.element(c("devtools", "R.utils"), installed.packages())
Rscript -e 'vec_req_cran_pkg <- c("devtools", "R.utils", "fs");vec_pkgidx_to_install <- (!is.element(vec_req_cran_pkg, installed.packages()));install.packages(vec_req_cran_pkg[vec_pkgidx_to_install], lib = "/home/zws/lib/R/library", repos="https://cran.rstudio.com")'

# in case package update was specified, then update, otherwise only if package is not available
if [ "$PACKAGEUPDATE" == "TRUE" ]
then
  # update anyway
  Rscript -e 'devtools::install_github("pvrqualitasag/zwsroutinetools", lib = "/home/zws/lib/R/library")'
else
  # check whether zwsroutinetools are installed
  Rscript -e 'if (!is.element("zwsroutinetools", installed.packages())) devtools::install_github("pvrqualitasag/zwsroutinetools", lib = "/home/zws/lib/R/library")'
fi

# create the comparison report
Rscript -e "zwsroutinetools::create_ge_compare_plot_report_${TRAIT}(ps_cur_ge_label='${CURGE}', ps_prev_ge_label = '${PREVGE}', ps_prevgsrun_label = '${PREVGS}', pb_debug=TRUE)"


### # ====================================================================== #
### # Script ends here
end_msg



### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

    -

=head1 SYNOPSIS


=head1 DESCRIPTION

Create report with comparison plots of two GE rounds


=head2 Requirements




=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>


=head1 DATE

2019-07-08 10:48:12

=cut
