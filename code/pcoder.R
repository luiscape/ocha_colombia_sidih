## Script to label correctly p-codes. 
columnJoin <- function(df = NULL) { 
    pcode <- 'NA'
    pb <- txtProgressBar(min = 0, max = nrow(df), style = 3)
    tot_copied <- 0
    message('Unifying the admin columns into a single column.')
    for (i in 1:nrow(df)) {
        setTxtProgressBar(pb, i)  # Updates progress bar.
        if(is.na(df$ID_MUN[i]) == TRUE) {
                pcode[i] <- df$ID_DEPTO[i]
                if (tot_copied == 0) tot_copied <- 1
                else tot_copied <- tot_copied + 1
        }
        else pcode[i] <- df$ID_MUN[i]
    }
    df <- cbind(df, pcode)
    df$pcode <- paste0("COL-", pcode)
    message(paste('A total number of:', tot_copied, 'rows were copied.'))
    df
}