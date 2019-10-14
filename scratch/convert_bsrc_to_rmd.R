#' ---
#' title:   Convert a bash script to Rmd
#' date:    "`r Sys.Date()`"
#' author:  Peter von Rohr
#' ---
#'
#'
#' ## Disclaimer
#' Experiments with converting a bash script to an Rmd document.
#'
#'
#' ## Input
#' Read the script
#+ input
rm(list = ls())
vec_bsrc <- readLines(con = 'inst/bash/install_script.sh')

#' In case the script starts with the path to bash remove it.
vec_our_src <- vec_bsrc
if (vec_our_src[1] == '#!/bin/bash')
  vec_our_src <- vec_our_src[-1]

#' Insert the chunk borders
#' There are two types of chunks:
#'
#' 1. text chunks where text chunks are all lines that start with "#'"
#' 2. code chunks are all lines that are not text chunks.
#'
#' From the definitions given above it seams easier to start with text chunks
#+ text-chunks
vec_txt_chunks <- grep("^#\\'", vec_our_src)


#' Start with the beginning of a code chunk
#+ start-code
vec_code_chunk_start_pos <- grep(pattern = '^#\\+', vec_our_src)
vec_code_chunk_start_pos

#' End of code chunks
#+ end-code
vec_txt_chunks <- c(vec_txt_chunks, length(vec_our_src))
vec_code_chunk_end_pos <- sapply(1:length(vec_code_chunk_start_pos),
                                 function(x) vec_txt_chunks[which(vec_code_chunk_start_pos[x]<vec_txt_chunks)[1]]-1,
                                 USE.NAMES = FALSE)
vec_code_chunk_end_pos


if (length(vec_code_chunk_start_pos) != length(vec_code_chunk_end_pos))
  stop("ERROR: number of code start pos not the same as code end pos")


#' ## Replacements to get to a rmd document
#' The code chunks are augmented with the tiks and engine specs
#+ code-chunk-start
(vec_our_src[vec_code_chunk_start_pos] <- gsub(pattern = '^#\\+(.*)$', replacement = '```{bash,\\1}', vec_our_src[vec_code_chunk_start_pos]))
vec_our_src

#' The code chunk ends are symbolised with three tiks which are added at each beginning of the line
#+ code-chunk-end
# vec_our_src[vec_code_chunk_end_pos] <- sapply(vec_code_chunk_end_pos, function(x) paste0("```\\\\n", vec_our_src[x]), USE.NAMES = FALSE)
for (i in seq_along(vec_code_chunk_end_pos)){
  cat("i: ", i, "\n")
  if (vec_our_src[vec_code_chunk_end_pos[i]] == ""){
    vec_our_src[vec_code_chunk_end_pos[i]] <- "```\n"
  } else {
    vec_our_src <- c(vec_our_src[1:(vec_code_chunk_end_pos[i])], "```\n", vec_our_src[(vec_code_chunk_end_pos[i]+1):length(vec_our_src)])
  }
}
vec_our_src

#' Remove all doxygen comment signs from text
vec_our_src <- gsub(pattern = "^#\\'[ ]*", replacement = "", vec_our_src )

cat(paste0(vec_our_src, collapse = "\n"), "\n", file = 'install_script.Rmd')

