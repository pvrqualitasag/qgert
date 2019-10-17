###
###
###
###   Purpose:   Create a Comparison Plot Report for FBK
###   started:   2019-10-14 (pvr)
###
### ########################################################## ###


## -- Creator Function for FBK ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Fruchtbarkeit (FBK)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group FBK.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @param plogger log4r logger object
#'
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_fbk(pn_cur_ge_label  = 1908,
#'                                   pn_prev_ge_label = 1904,
#'                                   pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_fbk
create_ge_compare_plot_report_fbk <- function(pn_cur_ge_label,
                                              pn_prev_ge_label,
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'qgert'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE,
                                              plogger      = NULL){
  # debugging message at the beginning
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'create_ge_compare_plot_report_fbk.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = " Start of function create_ge_compare_plot_report_fbk ... ")
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_fbk()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))

    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("YearMinus0/compare", sex))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "fbk/work",
                              breed,
                              paste0("YearMinus0/compare", sex))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- glue::glue('## Comparison Of Plots\n',
                                   'Plots compare estimates of Fruchtbarkeit (FBK) for {tolower(sex)}',
                                   ' of breed {breed}',
                                   ' between GE-run {pn_prev_ge_label}',
                                   ' on the left and the current GE-run {pn_cur_ge_label}',
                                   ' on the right.')
      # s_report_text  <- paste0('## Comparison Of Plots\nPlots compare estimates of Fruchtbarkeit (FBK) for ', tolower(sex),
      #                          ' of breed ', breed,
      #                          ' between GE-run ', pn_prev_ge_label,
      #                          ' on the left and the current GE-run ', pn_cur_ge_label,
      #                          ' on the right.', collapse = "")

      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_fbk_compare', sex, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Path to report created: ", s_rep_path))

      # create the report
      create_ge_plot_report(ps_gedir      = s_ge_dir,
                           ps_archdir     = s_arch_dir,
                           ps_trgdir      = s_trg_dir,
                           ps_templ       = ps_template,
                           ps_report_text = s_report_text,
                           ps_rmd_report  = s_rep_path,
                           pb_debug       = TRUE)
    }
  }

  # debugging message at the end
  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = " * End of function create_ge_compare_plot_report_fbk")

  # return nothing
  return(invisible(NULL))
}
