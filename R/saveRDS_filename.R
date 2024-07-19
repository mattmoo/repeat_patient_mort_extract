#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param obj
#' @param filename
#' @param path
#' @return
#' @author mattmoo
#' @export
saveRDS_filename <- function(obj, filename, dir) {
  
  out_path = file.path(dir, filename)
  
  saveRDS(obj, file.path(dir, filename))
  
  return(out_path)

}
