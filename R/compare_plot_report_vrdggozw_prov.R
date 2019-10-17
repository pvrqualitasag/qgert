###
###
###
###   Purpose:   Create a Rmd report with plots from two GE
###   started:   2019-07-02 (pvr)
###
### ########################################################## ###


## --- Creator Function for VRDGGOZW_PROV ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For VRDGGOZW_PROV
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for VRDGGOZW_PROV
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_prevgsrun_label label of bi-weekly gs-runs before publication date of pn_prev_ge_label
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @param plogger log4r logger object
#'
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_vrdggozw_prov(pn_cur_ge_label    = '1908',
#'                                        pn_prev_ge_label   = '1904',
#'                                        ps_prevgsrun_label = '0719',
#'                                        pb_debug           = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_vrdggozw_prov
create_ge_compare_plot_report_vrdggozw_prov <- function(pn_cur_ge_label,
                                               pn_prev_ge_label,
                                               ps_prevgsrun_label,
                                               ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'qgert'),
                                               pl_plot_opts = NULL,
                                               pb_debug     = FALSE,
                                               plogger       = NULL){
  # debugging message at the beginning
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'create_ge_compare_plot_report_vrdggozw_prov.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = " Start of function create_ge_compare_plot_report_vrdggozw_prov ... ")
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                   ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                   ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_vrdggozw_prov()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over types of zw
    for (zwt in l_plot_opts$vec_zw_type){
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Loop for zw-type: ", zwt, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem,
                            paste0(breed, "basis", collapse = ""),
                            paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "calcVRDGGOZW",
                              paste0("result", ps_prevgsrun_label, collapse = ""),
                              paste0(breed, "basis", collapse = ""),
                              paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn

      # TODO: replace the following with glue::glue()
      s_report_text <- l_plot_opts$report_text
      # s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
      #                               pl_replacement = list(list(pattern = "[ZWTYPE]", replacement = zwt),
      #                                                     list(pattern = "[BREED]",  replacement = breed),
      #                                                     list(pattern = "[PREVGERUN]", replacement = pn_prev_ge_label),
      #                                                     list(pattern = "[CURGERUN]", replacement = pn_cur_ge_label)))

      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_vrdggozw_prov_compare_', breed, '_',zwt, '.Rmd', collapse = ''))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
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
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
             ps_msg    = " * End of function create_ge_compare_plot_report_vrdggozw_prov")

  # return nothing
  return(invisible(NULL))
}
