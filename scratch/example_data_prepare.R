#' ---
#' title: Prepare Small Example Data
#' date:  "`r Sys.Date()`"
#' ---
#'
#' Data are copied from the evaluation directory and from the archive to the `inst/extdata` of this package.
#' ```{bash}
#' # current results
#' mkdir -p inst/extdata
#' cd inst/extdata
#' cp /Volumes/data_zws/fbk/work/bv/YearMinus0/bullRes_fbk.txt bullRes_fbk_1908.txt
#' ```
#'
#' ```{bash}
#' # archive
#' cp /Volumes/data_archiv/zws/1904/fbk/work/bv/YearMinus0/bullRes_fbk.txt.gz .
#' gunzip bullRes_fbk.txt.gz
#' mv bullRes_fbk.txt bullRes_fbk_1904.txt
#' ```
#'
#' The set of animals in the two datasets must be the same otherwise the plot cannot be done.
#+ define-resultpaths
s_current_result_path <- "inst/extdata/bullRes_fbk_1908.txt"
s_previous_result_path <- "inst/extdata/bullRes_fbk_1904.txt"


#' Read both datasets and join on animal id
#+ read-data
tbl_current <- readr::read_delim(file = s_current_result_path,
                                 delim = ' ')

tbl_previous <- readr::read_delim(file = s_previous_result_path,
                                 delim = ' ')

library(dplyr)
tbl_common_ids <- tbl_current %>%
  inner_join(tbl_previous, by = c('idaItb16' = 'idaItb16')) %>%
  head(n=1000) %>%
  select(idaItb16) %>%
  unique()

tbl_common_ids %>% head()
tbl_common_ids %>% tail()

#' The records in the current and the previous results for the common ids are written to test files
#+ common-result
(tbl_common_current <- tbl_current %>%
  inner_join(tbl_common_ids, by = c("idaItb16" = "idaItb16")) %>%
    arrange(idaItb16))
readr::write_delim(tbl_common_current, path = 'inst/extdata/current_results.txt')

(tbl_common_previous <- tbl_previous %>%
    inner_join(tbl_common_ids, by = c("idaItb16" = "idaItb16")) %>%
    arrange(idaItb16))
readr::write_delim(tbl_common_previous, path = 'inst/extdata/previous_results.txt')


