## Script to label correctly p-codes. 
columnJoin <- function(df = NULL) { 
    pcode <- 'NA'
    pb <- txtProgressBar(min = 0, max = nrow(df), style = 3)
    tot_copied <- 0
    message('Unifying two columns into one.')
    for (i in 1:nrow(df)) {
        setTxtProgressBar(pb, i)  # Updates progress bar.
        if(is.na(df$period.x[i]) == TRUE) {
                period[i] <- df$period.y[i]
                if (tot_copied == 0) tot_copied <- 1
                else tot_copied <- tot_copied + 1
        }
        else period[i] <- df$period.x[i]
    }
    df <- cbind(df, period)
#     df$pcode <- paste0("COL-", pcode)
    message(paste('A total number of:', tot_copied, 'rows were copied.'))
    df
}