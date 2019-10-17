
#' clean up
#+ clean-up
rm(list = ls())

#' function arguments
#+ func-arg
ps_sh_hair = 'inst/bash/spin_script.sh'
ps_out_rmd  = paste0(fs::path_ext_remove(ps_sh_hair), ".Rmd")
pb_knit     = TRUE
pb_keep_src = FALSE

vec_bsrc <- readLines(con = ps_sh_hair)
vec_bsrc

vec_out_src <- vec_bsrc
if (vec_out_src[1] == '#!/bin/bash')
  vec_out_src <- vec_out_src[-1]


vec_txt_chunks <- grep("^#\\'", vec_out_src)


# Start with the beginning of a code chunk and differentiate between the chunks with and without the
#   eval option
vec_code_chunk_start_pos <- grep(pattern = '^#\\+', vec_out_src)
vec_code_chunk_start_pos

#
vec_code_chunk_with_eval_start_pos <- grep(pattern = '^#\\+(.*)eval(.*)$', vec_out_src)
vec_code_chunk_with_eval_start_pos

#
vec_code_chunk_wout_eval_start_pos <- setdiff(vec_code_chunk_start_pos, vec_code_chunk_with_eval_start_pos)
vec_code_chunk_wout_eval_start_pos

# End of code chunks
vec_txt_chunks <- c(vec_txt_chunks, length(vec_out_src))
vec_code_chunk_end_pos <- sapply(1:length(vec_code_chunk_start_pos),
                                 function(x) vec_txt_chunks[which(vec_code_chunk_start_pos[x]<vec_txt_chunks)[1]]-1,
                                 USE.NAMES = FALSE)
if (length(vec_code_chunk_start_pos) != length(vec_code_chunk_end_pos))
  stop("ERROR: number of code start pos not the same as code end pos")

vec_out_src
# ## Replacements to get to a rmd document
# The code chunks are augmented with the tiks and engine specs
vec_out_src[vec_code_chunk_with_eval_start_pos] <- gsub(pattern = '^#\\+(.*)$', replacement = '```{bash,\\1}', vec_out_src[vec_code_chunk_with_eval_start_pos])
vec_out_src[vec_code_chunk_wout_eval_start_pos] <- gsub(pattern = '^#\\+(.*)$', replacement = '```{bash,\\1, eval=FALSE}', vec_out_src[vec_code_chunk_wout_eval_start_pos])

vec_out_src
