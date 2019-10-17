#' ---
#' title:  Testing Comparison Plot Reports
#' date:   "`r Sys.Date()`"
#' ---
#'
#' ## Preparation
#' Create project subdirectory for testing
#+ prepare-test
cd /qualstorzws01/data_projekte/projekte
cp -r singularity_data_zws singularity_data_zws_cpr

#' ## Data Retrieval
#' Get data from 1908 evaluation for bv for testing
#+ get-bv-data
cd singularity_data_zws_cpr/fbk
mkdir -p work
cd work
cp -r /qualstorzws01/data_zws/fbk/work/bv .


#' ## Package Installation
#' Install the required packages
#+ pkg-inst
R -e 'install.packages("devtools", repo="https://stat.ethz.ch/CRAN/", dependencies=TRUE)' --no-save

R -e 'devtools::install_github("pvrqualitasag/qgert", upgrade = "always", dependencies = TRUE)' --no-save


#' ## Create Comparison Plot Report
#' The following R-stmt is specially used to work with the data in the project
#+ R-fun-call
R -e 'qgert::create_ge_compare_plot_report_fbk(pn_cur_ge_label=1908, pn_prev_ge_label = 1904, pl_plot_opts = list(ge_dir_stem = "/qualstorzws01/data_projekte/projekte/singularity_data_zws_cpr/fbk/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_report_stem = "ge_plot_report_fbk",
              vec_breed       = c("bv"),
              vec_sex         = c("Bull", "Cow")))' --no-save


In R:

remove.packages('qgert') # must be followed by restarting R
devtools::install_github("pvrqualitasag/qgert", upgrade = "always", dependencies = TRUE, force = TRUE)
qgert::create_ge_compare_plot_report_fbk(pn_cur_ge_label=1908,
                                         pn_prev_ge_label = 1904,
                                         pl_plot_opts = list(ge_dir_stem = "/qualstorzws01/data_projekte/projekte/singularity_data_zws_cpr/fbk/work",
                                                             arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
                                                             rmd_report_stem = "ge_plot_report_fbk",
                                                             vec_breed       = c("bv"),
                                                             vec_sex         = c("Bull", "Cow")))



