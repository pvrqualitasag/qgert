###
###
###
###   Purpose:   Create a Rmd report with plots from two GE
###   started:   2019-07-02 (pvr)
###
### ########################################################## ###

## -- Generic Comparison Plot Creator Function

#' @title Create Report With Plots From Two GE Periods
#'
#' @description
#' Based on a Rmarkdown Template (ps_templ) document all plots
#' in given GE directory (ps_gedir) are taken. For a given plot
#' in directory ps_gedir, a corresponding plot with the same
#' filename is searched in an archive directory (ps_archdir).
#' If such a plot is found, the two corresponding plots are
#' shown side-by-side in the generated Rmarkdown report.
#'
#' @param ps_gedir  directory with plots of current GE round
#' @param ps_archdir  archive directory with plots from previous GE
#' @param pstrgdir    target directory where plot files from archive are extracted, relative to ps_gedir
#' @param ps_templ  path to Rmarkdown template file
#' @param ps_report_text text that is included in the report before plotting
#' @param ps_rmd_report name of report source file
#' @param pb_debug flag indicating whether debug info is printed
#'
#' @examples
#' \dontrun{
#' create_ge_plot_report(ps_gedir       = "/Volumes/data_zws/fbk/work/bv/YearMinus0/compareBull",
#'                     ps_archdir     = "/Volumes/data_archiv/zws/1904/fbk/work/bv/YearMinus0/compareBull",
#'                     ps_trgdir      = "1904/compareBull",
#'                     ps_templ       = "inst/templates/compare_plots.Rmd.template",
#'                     ps_report_text = "## Comparison Of Plots\nPlots compare estimates of fbk for bulls of breed BV between GE-1904 on the left and the current GE-1908 on the right.",
#'                     ps_rmd_report  = 'ge_plot_report_fbk_compareBulls_bv.Rmd',
#'                     pb_debug       = TRUE)
#'
#' }
#' @export create_ge_plot_report
create_ge_plot_report <- function(ps_gedir,
                                  ps_archdir,
                                  ps_trgdir,
                                  ps_templ,
                                  ps_report_text,
                                  ps_rmd_report = 'ge_plot_report.Rmd',
                                  pb_debug      = FALSE){

  if (pb_debug) cat(" * Starting create_ge_plot_report ... \n")

  # ps_gedir and ps_archdir must esits
  if (!dir.exists(ps_gedir))
    stop("[ERROR -- create_ge_plot_report] Cannot find plot directory: ", ps_gedir, "\n")

  if (!dir.exists(ps_archdir))
    stop("[ERROR -- create_ge_plot_report] Cannot find archive directory: ", ps_archdir, "\n")

  # ps_templ must exist
  if (!file.exists(ps_templ))
    stop("[ERROR -- create_ge_plot_report] Cannot find Rmd template: ", ps_templ, "\n")

  # target directory should be relative to ps_gedir
  if (fs::is_absolute_path(path = ps_trgdir))
    stop("[ERROR -- create_ge_plot_report] Target directory: ", ps_trgdir, " must be relative to ps_gedir: ", ps_gedir, "\n")
  # append ps_trgdir to ps_gedir
  s_trgdir <- file.path(ps_gedir, ps_trgdir)
  if (pb_debug) cat(" * Absolute target directory: ", s_trgdir, "\n")

  # get the root subdirectory in ps_gedir where ps_trgdir is added
  s_trgroot <- file.path(ps_gedir, fs::path_split(ps_trgdir)[[1]][1])
  if (pb_debug) cat(" * Target root directory: ", s_trgroot, "\n")

  # if the ps_trgdir does not exist, create it
  if (!dir.exists(s_trgdir)) {
    if (pb_debug) cat(" * Create target directory: ",s_trgdir, "\n")
    dir.create(path = s_trgdir, recursive = TRUE)
  }

  # if target directory could not be created, stop here
  if (!dir.exists(s_trgdir))
    stop("[ERROR -- create_ge_plot_report] Cannot create target directory: ", s_trgdir, "\n")

  # if the pdf report and the rmd sources exist, delete them first
  s_pdf_report <- fs::path_ext_set(fs::path_ext_remove(ps_rmd_report), "pdf")
  if (file.exists(s_pdf_report)){
    fs::file_delete(s_pdf_report)
    if (pb_debug) cat(" * Deleted existing pdf report: ", s_pdf_report, "\n")
  }
  # remove existing tex sources
  s_tex_report <- fs::path_ext_set(fs::path_ext_remove(ps_rmd_report), "tex")
  if (file.exists(s_tex_report)){
    fs::file_delete(s_tex_report)
    if (pb_debug) cat(" * Deleted existing tex report sources: ", s_tex_report, "\n")
  }
  # remove existing rmd source
  if (file.exists(ps_rmd_report)){
    fs::file_delete(ps_rmd_report)
    if (pb_debug) cat(" * Deleted existing rmd report source: ", ps_rmd_report, "\n")
  }

  # start with a new rmd rouce report by renaming the template into the result report
  file.copy(from = ps_templ, to = ps_rmd_report)

  # add the report text to the report
  cat(ps_report_text, "\n\n", file = ps_rmd_report, append = TRUE)

  # extract plot files from current ps_gedir
  vec_plot_files_ge <- list.files(ps_gedir, pattern = "\\.png$|\\.pdf$", full.names = TRUE)
  if (pb_debug){
    cat("Plot files in ", ps_gedir, "\n")
    print(vec_plot_files_ge)
  }
  # loop over plot files and get corresponding plot file from previous ge, if it exists
  for (f in vec_plot_files_ge){
    if (pb_debug) cat(" * Plot file: ", f, "\n")
    # write the chunk start into the report file
    cat("\n```{r, echo=FALSE, fig.show='hold', out.width='50%'}\n", file = ps_rmd_report, append = TRUE)
    # check whether corresponding plot file existed in archive
    bnf <- basename(f)
    # path to unzipped plot file in archive
    bnfarchpath <- file.path(ps_archdir, bnf)
    # gzipped plotfile
    bnfgz <- paste(bnf, "gz", sep = ".")
    # path to gzipped plotfile in archive
    bnfgzarchpath <- file.path(ps_archdir, bnfgz)
    # path to plotfile in target directory
    bnftrgpath <- file.path(s_trgdir, bnf)
    ### # TODO: the following can be refactored into functions that copy and gunzip archive files
    if (file.exists(bnfgzarchpath)){
      if (pb_debug) cat(" * Found archived plot file: ", bnfgz, " in ", ps_archdir, "\n")
      # copy file from archive
      if (pb_debug) cat(" * Copy from: ", bnfgzarchpath, " to ", s_trgdir, "\n")
      file.copy(from = bnfgzarchpath, to = s_trgdir)
      bnfgztrgpath <- file.path(s_trgdir, bnfgz)
      if (!file.exists(bnftrgpath)){
        if (pb_debug) cat(" * Unzip: ", bnfgztrgpath, "\n")
        R.utils::gunzip(bnfgztrgpath)
      } else {
        if (pb_debug) cat(" * File: ", bnftrgpath, " already exists", "\n")
      }
      ### # Include extracted file into the report
      cat(paste0("knitr::include_graphics(path = '", bnftrgpath, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    } else if (file.exists(bnfarchpath)) {
      if (pb_debug) cat(" * Found archived plot file: ", bnf, " in ", ps_archdir, "\n")
      # copy file from archive
      if (pb_debug) cat(" * Copy from: ", bnfarchpath, " to ", s_trgdir, "\n")
      file.copy(from = bnfarchpath, to = s_trgdir)
      ### # Include extracted file into the report
      cat(paste0("knitr::include_graphics(path = '", bnftrgpath, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    } else {
      if (pb_debug) cat(" * Cannot find archived plot file: ", bnfgz, " in ", ps_archdir, "\n")
    }
    # include current plot file into report
    cat(paste0("knitr::include_graphics(path = '", f, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    # write junk end into report
    cat("```\n\n", file = ps_rmd_report, append = TRUE)
  }
  # finally include session info into the report
  cat("\n```{r}\n sessioninfo::session_info()\n```\n\n", file = ps_rmd_report, append = TRUE)
  # render the generated Rmd file
  rmarkdown::render(input = ps_rmd_report)

  # remove report sources
  if (pb_debug) cat(" * Removing report rmd source ", ps_rmd_report, "\n")
  fs::file_delete(ps_rmd_report)
  if (pb_debug) cat(" * Removing report tex source ", s_tex_report, "\n")
  fs::file_delete(s_tex_report)

  # remove target root dir
  if (pb_debug) cat(" * Delete target root directory: ", s_trgroot, "\n")
  fs::dir_delete(path = s_trgroot)

  if (pb_debug) cat(" * End of create_ge_plot_report\n")

  # return nothing
  return(invisible(NULL))
}


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
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = " * Start of function create_ge_compare_plot_report_fbk")
    log_info(ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_fbk",
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
      log_info(ps_caller = "create_ge_compare_plot_report_fbk",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))

    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("YearMinus0/compare", sex))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "fbk/work",
                              breed,
                              paste0("YearMinus0/compare", sex))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- paste0('## Comparison Of Plots\nPlots compare estimates of Fruchtbarkeit (FBK) for ', tolower(sex),
                               ' of breed ', breed,
                               ' between GE-run ', pn_prev_ge_label,
                               ' on the left and the current GE-run ', pn_cur_ge_label,
                               ' on the right.', collapse = "")
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[SEX]", replacement = tolower(sex)),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))

      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_fbk_compare', sex, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_fbk",
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
    log_info(ps_caller = "create_ge_compare_plot_report_fbk",
             ps_msg    = " * End of function create_ge_compare_plot_report_fbk")

  # return nothing
  return(invisible(NULL))
}


## -- Creator Function for ND ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Nutzungsdauer (ND)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group ND.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_nd(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_nd
create_ge_compare_plot_report_nd <- function(pn_cur_ge_label,
                                              pn_prev_ge_label,
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_nd",
             ps_msg    = " * Start of function create_ge_compare_plot_report_nd")
    log_info(ps_caller = "create_ge_compare_plot_report_nd",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_nd",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_nd()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))


    # put together all directory names, start with GE working directory
    s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, "compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
               ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
    # archive directory
    s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                            pn_prev_ge_label,
                            "nd/work",
                            breed,"YearMinus0/compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
               ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

    # Report text appears in all reports of this trait before the plots are drawn
    s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                  pl_replacement = list(list(pattern = "[BREED]",  replacement = breed),
                                                        list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                        list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
               ps_msg    = paste0(" ** Report text: ", s_report_text))

    # target directory
    l_arch_dir_split <- fs::path_split(s_arch_dir)
    s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
               ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

    # specify the name of the report file
    s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_nd_compare_', breed, '.Rmd', collapse = ''))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_nd",
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

  # debugging message at the end
  if (pb_debug)
    log_info(ps_caller = "create_ge_compare_plot_report_nd",
             ps_msg    = " * End of function create_ge_compare_plot_report_nd")

  # return nothing
  return(invisible(NULL))
}


## -- Creator Function for MAR ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Mastitisresistenz (MAR)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group MAR.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_mar(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_mar
create_ge_compare_plot_report_mar <- function(pn_cur_ge_label,
                                             pn_prev_ge_label,
                                             ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                             pl_plot_opts = NULL,
                                             pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_mar",
             ps_msg    = " * Start of function create_ge_compare_plot_report_mar")
    log_info(ps_caller = "create_ge_compare_plot_report_mar",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_mar",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_mar()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_mar",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_mar",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

     # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("zws/compare", sex, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_mar",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "health/mar/work",
                              breed,paste0("zws/compare", sex, collapse = ""))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_mar",
               ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

    # Report text appears in all reports of this trait before the plots are drawn
    s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                  pl_replacement = list(list(pattern = "[SEX]", replacement = tolower(sex)),
                                                        list(pattern = "[BREED]",  replacement = breed),
                                                        list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                        list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))

    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_mar",
               ps_msg    = paste0(" ** Report text: ", s_report_text))

    # target directory
    l_arch_dir_split <- fs::path_split(s_arch_dir)
    s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_mar",
               ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

    # specify the name of the report file
    s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_mar_compare_', sex, '_', breed, '.Rmd', collapse = ''))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_mar",
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
    log_info(ps_caller = "create_ge_compare_plot_report_mar",
             ps_msg    = " * End of function create_ge_compare_plot_report_mar")

  # return nothing
  return(invisible(NULL))
}


## -- Creator Function for LBE ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Lineare Beschreibung (LBE)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group LBE.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_lbe(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_lbe
create_ge_compare_plot_report_lbe <- function(pn_cur_ge_label,
                                              pn_prev_ge_label,
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_lbe",
             ps_msg    = " * Start of function create_ge_compare_plot_report_lbe")
    log_info(ps_caller = "create_ge_compare_plot_report_lbe",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_lbe",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_lbe()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_lbe",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("YearMinus0/compare", sex, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "lbe/work",
                              breed,paste0("YearMinus0/compare", sex, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[SEX]", replacement = tolower(sex)),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))

      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_lbe_compare_', sex, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe",
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
    log_info(ps_caller = "create_ge_compare_plot_report_lbe",
             ps_msg    = " * End of function create_ge_compare_plot_report_lbe")

  # return nothing
  return(invisible(NULL))
}


## -- Creator Function for LBE_RH ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Lineare Beschreibung For RH (LBE_RH)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group LBE_RH.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_lbe_rh(pn_cur_ge_label  = 1908,
#'                                      pn_prev_ge_label = 1904,
#'                                      pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_lbe_rh
create_ge_compare_plot_report_lbe_rh <- function(pn_cur_ge_label,
                                                 pn_prev_ge_label,
                                                 ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                                 pl_plot_opts = NULL,
                                                 pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
             ps_msg    = " * Start of function create_ge_compare_plot_report_lbe_rh")
    log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_lbe_rh()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("compare", sex, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "lbe_rh/work",
                              breed,paste0("compare", sex, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[SEX]", replacement = tolower(sex)),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0(l_plot_opts$rmd_report_stem, '_compare_', sex, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
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
    log_info(ps_caller = "create_ge_compare_plot_report_lbe_rh",
             ps_msg    = " * End of function create_ge_compare_plot_report_lbe")

  # return nothing
  return(invisible(NULL))
}



## -- Creator Function for PROD ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Production (PROD)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group PROD.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_prod(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_prod
create_ge_compare_plot_report_prod <- function(pn_cur_ge_label,
                                              pn_prev_ge_label,
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_prod",
             ps_msg    = " * Start of function create_ge_compare_plot_report_prod")
    log_info(ps_caller = "create_ge_compare_plot_report_prod",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_prod",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_prod()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_prod",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over both sexes
    for (sex in l_plot_opts$vec_sex){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
                 ps_msg    = paste0(" ** Loop for sex: ", sex, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, paste0("compare_", tolower(sex), collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              pn_prev_ge_label,
                              "prod/work",
                              breed,paste0("compare_", tolower(sex), collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[SEX]", replacement = tolower(sex)),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_prod_compare_', sex, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_prod",
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
    log_info(ps_caller = "create_ge_compare_plot_report_prod",
             ps_msg    = " * End of function create_ge_compare_plot_report_prod")

  # return nothing
  return(invisible(NULL))
}


## --- Creator Function for VRDGGOZW_PROV ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For VRDGGOZW_PROV
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for VRDGGOZW_PROV
#'
#' @param ps_cur_ge_label label of current genetic evaluation (GE)
#' @param ps_prev_ge_label label of previous GE
#' @param ps_prevgsrun_label label of bi-weekly gs-runs before publication date of ps_prev_ge_label
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_vrdggozw_prov(ps_cur_ge_label    = '1908',
#'                                        ps_prev_ge_label   = '1904',
#'                                        ps_prevgsrun_label = '0719',
#'                                        pb_debug           = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_vrdggozw_prov
create_ge_compare_plot_report_vrdggozw_prov <- function(ps_cur_ge_label,
                                               ps_prev_ge_label,
                                               ps_prevgsrun_label,
                                               ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                               pl_plot_opts = NULL,
                                               pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
             ps_msg    = " * Start of function create_ge_compare_plot_report_vrdggozw_prov")
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
             ps_msg    = paste0(" * Label of current GE: ", ps_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
             ps_msg    = paste0(" * Label of previous GE: ", ps_prev_ge_label))
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
      log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over types of zw
    for (zwt in l_plot_opts$vec_zw_type){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Loop for zw-type: ", zwt, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem,
                            paste0(breed, "basis", collapse = ""),
                            paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              ps_prev_ge_label,
                              "calcVRDGGOZW",
                              paste0("result", ps_prevgsrun_label, collapse = ""),
                              paste0(breed, "basis", collapse = ""),
                              paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[ZWTYPE]", replacement = zwt),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))

      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(ps_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_vrdggozw_prov_compare_', breed, '_',zwt, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
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
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw_prov",
             ps_msg    = " * End of function create_ge_compare_plot_report_vrdggozw_prov")

  # return nothing
  return(invisible(NULL))
}


## --- Creator Function for VRDGGOZW ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For VRDGGOZW
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for VRDGGOZW
#'
#' @param ps_cur_ge_label label of current genetic evaluation (GE)
#' @param ps_prev_ge_label label of previous GE
#' @param ps_prevgsrun_label label of bi-weekly gs-runs before publication date of ps_prev_ge_label
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_vrdggozw(ps_cur_ge_label    = '1908',
#'                                        ps_prev_ge_label   = '1904',
#'                                        ps_prevgsrun_label = '0719',
#'                                        pb_debug           = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_vrdggozw
create_ge_compare_plot_report_vrdggozw <- function(ps_cur_ge_label,
                                                   ps_prev_ge_label,
                                                   ps_prevgsrun_label,
                                                   ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                                   pl_plot_opts = NULL,
                                                   pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
             ps_msg    = " * Start of function create_ge_compare_plot_report_vrdggozw")
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
             ps_msg    = paste0(" * Label of current GE: ", ps_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
             ps_msg    = paste0(" * Label of previous GE: ", ps_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_vrdggozw()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))
    # loop over types of zw
    for (zwt in l_plot_opts$vec_zw_type){
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
                 ps_msg    = paste0(" ** Loop for zw-type: ", zwt, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(l_plot_opts$ge_dir_stem,
                            paste0(breed, "basis", collapse = ""),
                            paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                              ps_prev_ge_label,
                              "calcVRDGGOZW",
                              paste0("result", ps_prevgsrun_label, collapse = ""),
                              paste0(breed, "basis", collapse = ""),
                              paste0("comp", zwt, collapse = ""))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                    pl_replacement = list(list(pattern = "[ZWTYPE]", replacement = zwt),
                                                          list(pattern = "[BREED]",  replacement = breed),
                                                          list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                          list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))

      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(ps_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_vrdggozw_compare_', breed, '_',zwt, '.Rmd', collapse = ''))
      if (pb_debug)
        log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
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
    log_info(ps_caller = "create_ge_compare_plot_report_vrdggozw",
             ps_msg    = " * End of function create_ge_compare_plot_report_vrdggozw")

  # return nothing
  return(invisible(NULL))
}



## -- Creator Function for ITB ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Interbull (ITB)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the trait
#' group ITB.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_itb(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_itb
create_ge_compare_plot_report_itb <- function(ps_cur_ge_label,
                                               ps_prev_ge_label,
                                               ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                               pl_plot_opts = NULL,
                                               pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_itb",
             ps_msg    = " * Start of function create_ge_compare_plot_report_itb")
    log_info(ps_caller = "create_ge_compare_plot_report_itb",
             ps_msg    = paste0(" * Label of current GE: ", ps_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_itb",
             ps_msg    = paste0(" * Label of previous GE: ", ps_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_itb()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))

    # put together all directory names, start with GE working directory
    s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, "compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
               ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
    # archive directory
    s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                            ps_prev_ge_label,
                            "itb/work",
                            breed,"compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
               ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

    # Report text appears in all reports of this trait before the plots are drawn
    s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                  pl_replacement = list(list(pattern = "[BREED]",  replacement = breed),
                                                        list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                        list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
               ps_msg    = paste0(" ** Report text: ", s_report_text))

    # target directory
    l_arch_dir_split <- fs::path_split(s_arch_dir)
    s_trg_dir <- file.path(ps_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
               ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

    # specify the name of the report file
    s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_itb_compare_', breed, '.Rmd', collapse = ''))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_itb",
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

  # debugging message at the end
  if (pb_debug)
    log_info(ps_caller = "create_ge_compare_plot_report_itb",
             ps_msg    = " * End of function create_ge_compare_plot_report_itb")

  # return nothing
  return(invisible(NULL))
}



## -- Creator Function for CNVRH ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For Convert RH (CNVRH)
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for the plots produced
#' in the conversion of cow proofs for RH (CNVRH).
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_template template document for report
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_cnvrh(pn_cur_ge_label  = 1908,
#'                                  pn_prev_ge_label = 1904,
#'                                  pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_cnvrh
create_ge_compare_plot_report_cnvrh <- function(ps_cur_ge_label,
                                              ps_prev_ge_label,
                                              ps_template  = system.file("templates", "compare_plots.Rmd.template", package = 'zwsroutinetools'),
                                              pl_plot_opts = NULL,
                                              pb_debug     = FALSE){
  # debugging message at the beginning
  if (pb_debug) {
    log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
             ps_msg    = " * Start of function create_ge_compare_plot_report_cnvrh")
    log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
             ps_msg    = paste0(" * Label of current GE: ", ps_cur_ge_label))
    log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
             ps_msg    = paste0(" * Label of previous GE: ", ps_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_cnvrh()
  }


  # loop over breeds
  for (breed in l_plot_opts$vec_breed){
    # loop over breeds
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))

    # put together all directory names, start with GE working directory
    s_ge_dir <- file.path(l_plot_opts$ge_dir_stem, breed, "compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
               ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
    # archive directory
    s_arch_dir <- file.path(l_plot_opts$arch_dir_stem,
                            ps_prev_ge_label,
                            "convert/work",
                            breed,"compare")
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
               ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

    # Report text appears in all reports of this trait before the plots are drawn
    s_report_text  <- replace_plh(ps_report_text = l_plot_opts$report_text,
                                  pl_replacement = list(list(pattern = "[BREED]",  replacement = breed),
                                                        list(pattern = "[PREVGERUN]", replacement = ps_prev_ge_label),
                                                        list(pattern = "[CURGERUN]", replacement = ps_cur_ge_label)))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
               ps_msg    = paste0(" ** Report text: ", s_report_text))

    # target directory
    l_arch_dir_split <- fs::path_split(s_arch_dir)
    s_trg_dir <- file.path(ps_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
               ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

    # specify the name of the report file
    s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_cnvrh_compare_', breed, '.Rmd', collapse = ''))
    if (pb_debug)
      log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
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

  # debugging message at the end
  if (pb_debug)
    log_info(ps_caller = "create_ge_compare_plot_report_cnvrh",
             ps_msg    = " * End of function create_ge_compare_plot_report_cnvrh")

  # return nothing
  return(invisible(NULL))
}








