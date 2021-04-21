

### unroll qgert::create_toplist_bvch_bull(ps_eval_label = '2008')

devtools::load_all()
ps_eval_label = '2008'
pl_breed_input  = get_l_breed_input_bvch()
ptbl_trait_name = get_default_tbl_trait_name_bvch()
ps_xlsx_file    = NULL
pb_debug        = FALSE
plogger         = NULL

vec_non_trait <- get_vec_non_traits()

# l_toplist_info <- read_top_list_info3(pl_breed_input  = pl_breed_input,
#                                       ptbl_trait      = ptbl_trait_name,
#                                       pb_debug        = pb_debug,
#                                       plogger         = plogger)

pl_breed_input  = pl_breed_input
ptbl_trait      = ptbl_trait_name
pb_debug        = pb_debug
plogger         = plogger
pvec_resultcols = get_vec_resultcols_bvch()

vec_trait <- ptbl_trait$Abk

l_final_result <- NULL

### # loop over breeds and do the extraction
#for (nbidx in seq_along(pl_breed_input$breeds)){
  nbidx <- 1
  ### # read current input file
  tbl_cur_tl <- readr::read_csv2(file = pl_breed_input$inputfiles[nbidx])
  ### # extract the current result
  l_cur_result <- lapply(vec_trait,
                         function(x) {
    if (x %in% names(tbl_cur_tl)){
      tbl_cur_trait <- dplyr::bind_cols(tibble::tibble(Rang = 1:pl_breed_input$numbertop[nbidx]),
                                        tbl_cur_tl[order(tbl_cur_tl[[x]], decreasing = TRUE),
                                                   c(pvec_resultcols, x)][1:pl_breed_input$numbertop[nbidx],])
      names(tbl_cur_trait)[ncol(tbl_cur_trait)] <- ptbl_trait[ptbl_trait$Abk == x,]$Name
      return(tbl_cur_trait)
    } else {
      return(NULL)
    }})

  x <- vec_trait[1]

  names(l_cur_result) <- vec_trait
  ### # add current result to final result
  l_final_result <- c(l_final_result, list(l_cur_result))
}



### # tests
tbl_cur_test <- tibble::tibble(GZW = c(1000, 1000, 200, 250), MIW = c(10, 20, 300, 300))
order(tbl_cur_test[["GZW"]], tbl_cur_test[["MIW"]], decreasing = TRUE)
order(tbl_cur_test[["MIW"]], tbl_cur_test[["GZW"]], decreasing = TRUE)


ptbl_trait <- dplyr::bind_cols(ptbl_trait, tibble::tibble(Secondary = c("MIW", rep("GZW", (nrow(ptbl_trait)-1)))))
l_sort <- lapply(1:nrow(ptbl_trait), function(x) return(c(ptbl_trait$Abk[x], ptbl_trait$Secondary[x])) )
names(l_sort) <- ptbl_trait$Abk

lapply(l_sort, function(x) {
  if (x[1] %in% names(tbl_cur_tl)){
  tbl_cur_trait <- dplyr::bind_cols(tibble::tibble(Rang = 1:pl_breed_input$numbertop[nbidx]),
                                    tbl_cur_tl[order(tbl_cur_tl[[x[1]]], tbl_cur_tl[[x[2]]], decreasing = TRUE),
                                               c(pvec_resultcols, x[1], x[2])][1:pl_breed_input$numbertop[nbidx],])
  names(tbl_cur_trait)[ncol(tbl_cur_trait)] <- ptbl_trait[ptbl_trait$Abk == x[1],]$Name
  return(tbl_cur_trait)
} else {
  return(NULL)
}})

