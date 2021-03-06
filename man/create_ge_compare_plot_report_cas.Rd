% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare_plot_report_cas.R
\name{create_ge_compare_plot_report_cas}
\alias{create_ge_compare_plot_report_cas}
\title{Comparison Plot Report Creator Function For Aufzuchtverlust (CAS)}
\usage{
create_ge_compare_plot_report_cas(
  pn_cur_ge_label,
  pn_prev_ge_label,
  ps_cur_plot_root = NULL,
  ps_prev_plot_root = NULL,
  ps_template = system.file("templates", "compare_plots.Rmd.template", package =
    "qgert"),
  ps_breed = NULL,
  pl_plot_opts = NULL,
  pb_debug = FALSE,
  plogger = NULL
)
}
\arguments{
\item{pn_cur_ge_label}{label of current genetic evaluation (GE)}

\item{pn_prev_ge_label}{label of previous GE}

\item{ps_cur_plot_root}{directory with plots of current evaluation}

\item{ps_prev_plot_root}{directory with plots from previous evaluation}

\item{ps_template}{template document for report}

\item{ps_breed}{create comparison plot report for just one breed}

\item{pl_plot_opts}{list of options specifying input for plot report creator}

\item{pb_debug}{flag whether debug output should be shown}

\item{plogger}{log4r logger object}
}
\description{
A comparison plot report containing all generated plots of a GE side-by-side
with the plots from the previous GE are constructed for the trait
group CAS.
}
\examples{
\dontrun{
create_ge_compare_plot_report_cas(pn_cur_ge_label  = 1908,
                                  pn_prev_ge_label = 1904,
                                  pb_debug = TRUE)
}

}
