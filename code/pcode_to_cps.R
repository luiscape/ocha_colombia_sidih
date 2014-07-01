## Very simple script to adapt the p-codes at a national level to 
## CPS-like codes.
CPSify <- function(df = NULL, iso3 = NULL) {
    if (is.null(iso3) == TRUE) { stop('Please provide a 3 letter ISO3 code.') }
    else df$region <- paste(iso3, "-", df$region, sep = "")
    df
}