## Script to fix the encoding. 
# from http://tomizonor.wordpress.com/2013/04/15/encode-data-frame/

# this script saves data locally in a temp file and reloads it with 
# the correct encoding.
fixEncoding <- function(df, sep="\t", encoding="latin1") {
    rawtsv <- tempfile()
    write.table(df, file = rawtsv, sep = sep, quote = FALSE)
    result <- read.table(file(rawtsv, encoding=encoding), 
                         sep = sep, quote = "")
    unlink(rawtsv)
    result
}