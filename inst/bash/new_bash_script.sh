#!/bin/bash
###
###
###
###   Purpose:   Create new bash script based on a template
###   started:   2018-08-09 (pvr)
###
### ###################################################################### ###

# ======================================== # ======================================= #
# global constants                         #                                         #
# ---------------------------------------- # --------------------------------------- #
# prog paths                               #                                         #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
SED=`which sed`                            # PATH to sed                             #
WHOAMI=/usr/bin/whoami                     # PATH to whoami                          #
DATE=/bin/date                             # PATH to date                            #
CP=/bin/cp                                 # PATH to cp                              #
MV=/bin/mv                                 # PATH to mv                              #
CHMOD=/bin/chmod                           # PATH to chmod                           #
# ---------------------------------------- # --------------------------------------- #
# directories                              #                                         #
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of this script         #
BASHTOOLDIR=`$DIRNAME $INSTALLDIR`         # directory of bashtools on host          #
UTILDIR=$BASHTOOLDIR/util                  # directory containing utilities          #
TEMPLATEDIR=$BASHTOOLDIR/template          # directory containing templates          #
# ---------------------------------------- # --------------------------------------- #
# files                                    #                                         #
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
# ======================================== # ======================================= #


# Use utilities
UTIL=$UTILDIR/bash_utils.sh
source $UTIL

# other constants
TEMPLATEPATH=$TEMPLATEDIR/bash/bash_script_so.template
GETTAGSCRIPT=$UTILDIR/get_template_tags.sh
OUTPUTPATH=`$DATE +"%Y%m%d%H%M%S"`_new_script.sh
DEFAULTSCRIPTRIGHT=755

# defaults for tags
STARTDATE=`$DATE +"%Y-%m-%d %H:%M:%S"`
AUTHORABBREV=`$WHOAMI`
AUTHORNAME=`$WHOAMI`


### # ====================================================================== #
### # functions


### # ====================================================================== #
### # Use getopts for commandline argument parsing                         ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
while getopts :o:qt:h FLAG; do
  case $FLAG in
    o) # set option -o to specify output file
      OUTPUTPATH=$OPTARG
      ;;
    q) # set option -s to run in silent mode without tag replacement
      QUIET=TRUE
      ;;
    t) # set option "-t"  to specify the template file
      TEMPLATEPATH=$OPTARG
	    ;;
	  h) # option -h shows usage
  	  usage $SCRIPT "Help message" "$SCRIPT -t <template_file>"
	    ;;
	  *) # invalid command line arguments
	    usage $SCRIPT "Invalid command line argument $OPTARG" "$SCRIPT -o <output_file> -t <template_file>"
	    ;;
  esac
done  

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.


### # ====================================================================== #
### # Main part of the script starts here ...
start_msg $SCRIPT

### # define output directory
OUTPUTDIR=`$DIRNAME $OUTPUTPATH`

### # if output directory is not the cwd, and it does not exist, create it
if [ "$OUTPUTDIR" != "." ]
then
  check_exist_dir_create $OUTPUTDIR
fi

### # checking prerequisits
check_exist_file_fail $TEMPLATEPATH
check_exist_file_fail $GETTAGSCRIPT


### # set the template to be the first version of the output
$CP $TEMPLATEPATH $OUTPUTPATH

### # in case, we are in silent mode, we stop here
if [ "$QUIET" == "TRUE" ]
then
  end_msg $SCRIPT
  exit 0
fi

### # in non-silent mode run tag replacement
### # in a loop over all tags in the template file, ask the user what value
### #  should be inserted into the template
tags=()
### # use process substitutions to collect the tags according to 
### #  https://stackoverflow.com/questions/9985076/bash-populate-an-array-in-loop
while read tag
do
  tags+=( ${tag} )
  # log_msg $SCRIPT "Current tag: $tag"
done < <($GETTAGSCRIPT -t $TEMPLATEPATH -u)

### # notify user that replacement values should be entered
log_msg $SCRIPT "Enter replacement values for template tags ..."

# loop over tags 
for i in ${!tags[@]}
do
  # log_msg $SCRIPT "Tag loop $i: ${tags[i]}"
  CURTAG=${tags[i]}
  # check for defaults
  defaultvalue=''
  if [ "$CURTAG" == "__STARTDATE__" ]
  then
    defaultvalue=$STARTDATE
  fi
  if [ "$CURTAG" == "__AUTHORABBREV__" ]
  then
    defaultvalue=$AUTHORABBREV
  fi
  if [ "$CURTAG" == "__AUTHORNAME__" ]
  then
    defaultvalue=$AUTHORNAME
  fi
  if [ "$CURTAG" == "__BASHTOOLUTILDIR__" ]
  then
    if [ -d "$UTILDIR" ]
    then
      defaultvalue=$UTILDIR
    else
      defaultvalue=NA
    fi
  fi
  # read input from command line
  read -p "$CURTAG [$defaultvalue]: " inputvalue
  # check whether default or input should be used
  if [ -z "$inputvalue" ]
  then
    replacevalue=$defaultvalue
  else
    replacevalue=$inputvalue
  fi
  # replacement of current tag
  $SED "s#$CURTAG#$replacevalue#g" < $OUTPUTPATH  > $OUTPUTPATH.new
  # prepare input of new round from output of current round
  $MV $OUTPUTPATH.new $OUTPUTPATH
done  

# change rights
log_msg "Changed rights of $OUTPUTPATH to $DEFAULTSCRIPTRIGHT"
$CHMOD $DEFAULTSCRIPTRIGHT $OUTPUTPATH


### # ====================================================================== #
### # Script ends here
end_msg $SCRIPT

### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

   new_bash_script - Create new bash script based on a template

=head1 SYNOPSIS

   new_bash_script.sh -o <output_file> -t <template_file> 
   
      additional recognized options:
        -q   running in quiet mode without template-tag replacement
        -h   show usage message
        

=head1 DESCRIPTION

Most bash scripts have a very similar structure. This is even more true with 
the requirements imposed by reproducible workflows. To make the creation of 
new bash scripts as seamless as possible, the common parts are collected into 
a template file. The components that vary between different bash scripts are 
denoted by so-called tags which are place-holders for certain chunks of 
information. When a new bash script is created these tags must be replaced 
by the actual values of a given script. 

This script asks the user for the actual values with which the different 
tags in a template should be replaced with.


=head2 Options

The following options can be used to parameterize the creation of a new script. 

  -o <output_file>   : specify the name of the newly created script
  -t <template_file> : specify the name of the template to be used
  -q                 : runs the script in quiet mode without template tag replacement
  -h                 : shows the usage message
  
None of the above options are mandatory. There are reasonable defaults for all parameters


=head2 Requirements

When specifying a template file, the template file must exist.


=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>

=cut
