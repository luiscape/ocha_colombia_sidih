## compare the imact of the Colombia data to our db ## 

download.file('https://raw.githubusercontent.com/luiscape/data-for-frog/master/frog_data/csv/value.csv', destfile = 'temp.csv', method = 'curl')

frog_data <- read.csv('temp.csv')
frog_data_sub <- frog_data[nchar(as.character(frog_data$period)) == 4, ]

# how much data we had before Colombia
frog_data_sub$period <- as.Date(frog_data_sub$period, format = "%Y")
frog_data_sub$source_plot <- 'cps'
ggplot(frog_data_sub) + theme_bw() + 
    geom_bar(aes(period, fill = dsID), stat = 'bin') +
    scale_x_date(limits = c(as.Date('1940', format = '%Y'), 
                            as.Date('2014', format = '%Y')))

# in grey
ggplot(frog_data_sub) + theme_bw() + 
    geom_bar(aes(period), stat = 'bin', fill = "#CCCCCC") +
    scale_x_date(limits = c(as.Date('1940', format = '%Y'), 
                            as.Date('2014', format = '%Y')))

# only Colombia
value_sub <- value[nchar(value$period) == 4, ]
value_sub$period <- as.Date(value_sub$period, format = '%Y')
value_sub$source_plot <- 'colombia'
ggplot(value_sub) + theme_bw() + 
    geom_bar(aes(period), stat = 'bin', fill = '#404040')

# all data
data_for_plot <- plyr::rbind.fill(frog_data_sub, value_sub)

# all data plot
ggplot(data_for_plot, aes(fill = dsID)) + theme_bw() + 
    geom_bar(aes(period), stat = 'bin') +
    scale_x_date(limits = c(as.Date('1940', format = '%Y'),
                            as.Date('2014', format = '%Y')))

