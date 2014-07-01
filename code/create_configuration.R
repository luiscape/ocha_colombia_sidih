## Script to create configuration file

createConfiguration <- function(src = NULL) {
    # configuration file
    # IndicatorType#source#indicatorConfiguration#value
    # Expected time format -- YYYY
    # Expected start time format -- YYYY-01-01
    
    #####################################
    #####################################
    ## Clarify the time formats in CPS.##
    #####################################
    #####################################
    
    IndicatorType <- indicator$indID
    source <- src
    indicatorConfiguration <- 'Expected time format'
    value_conf <- 'YYYY'
    configuration1 <- data.frame(IndicatorType, source, 
                                 indicatorConfiguration, value_conf)
    
    # it seems that we need two configurations for each file.
    IndicatorType <- indicator$indID
    source <- src
    indicatorConfiguration <- 'Expected start time format'
    value_conf <- 'YYYY-01-01'
    configuration2 <- data.frame(IndicatorType, source, 
                                 indicatorConfiguration, value_conf)
    
    configuration <- rbind(configuration1, configuration2)
    
    write.table(configuration, 'data/cps/configuration.csv', row.names = F, 
                col.names = F, sep = "#")
}

