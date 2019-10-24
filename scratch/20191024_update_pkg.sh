#' ---
#' title: Update Packaae and Scripts
#' date:  2019-10-24
#' ---
#'
#' After a new release of the package qgert, it must be installed

541  R -e 'devtools::install_github("pvrqualitasag/qgert")'
542  /home/zws/lib/R/library/qgert/bash/install_script.sh -s /home/zws/lib/R/library/qgert/bash/create_comp_plot_report_fbk.sh -t prog
543  ./prog/create_comp_plot_report_fbk.sh -c 1912 -p 1908
