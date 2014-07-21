## Plotting scripts.
library(ggplot2)
library(RCurl)

# loading data
value <- read.csv('data/cps/value.csv')

# function that takes one indicator as basis and generates a series of plots
plotIndicator <- function(df = NULL, indicator = NULL, admin = 2) {
    
    # sanity check
    if (is.null(df) == TRUE) stop('Remember to provide a data.frame.')
    if (is.null(indicator) == TRUE) stop('Remember to provide an indicator')
    if ((indicator %in% df$indicator) == FALSE) stop("The indicator isn't in the data.frame.")
    if (is.null(admin) == TRUE) stop('Provide an integer between 1 and 3')
    
    # subsetting data
    # only admins2 for now
    if (admin == 2) {
        ind_data <- df[df$indID == indicator, ]
        ind_data <- na.omit(ind_data)  # cleaning NAs -- check this on original file
        ind_data <- col_ind[nchar(as.character(ind_data$region)) == 5 |
                            nchar(as.character(ind_data$region)) == 6, ]
        ind_data$value <- as.numeric(ind_data$value)
    }
    
    # getting the location name from Divipola
    # not all codes are mapped in the latest
    # version of Divipola
    temporaryFile <- tempfile()
    download.file('https://raw.githubusercontent.com/luiscape/colombia_pcode/master/data/col_admin2.csv', destfile=temporaryFile, method="curl")
    admin2_names <- read.csv(temporaryFile)
    admin2_names[1] <- NULL  # dropping not necessary columns
    
    # getting the admin 2 names
    ind_data
    
    
}

y <- merge(x, admin2_names, by.x = 'region', by.y = 'hdx_pcode', all.x = TRUE)


# creating sparklines from the GDP indicators in the
# districts of Colombia
ggplot(col_ind_1, aes(period, value, group = region)) + theme_bw() +
    geom_line(stat = 'identity', size = 1, color = "#F1645A") +
    facet_wrap(~ region, scale = 'free_y') +
    theme(panel.border = element_rect(linetype = 0),
         strip.background = element_rect(colour = "white", fill = "white"),
#          strip.text = element_text(angle = 90, size = 10, hjust = 0.5, vjust = 0.5),
         panel.background = element_rect(colour = "white"),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         axis.text.x = element_blank(),
         axis.text.y = element_blank(),
         axis.ticks = element_blank()) +
    ylab("") + xlab("")
    