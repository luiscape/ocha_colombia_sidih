### Script to study the SIDIH indicators table 
### from their main database.
### The database is managed by Rubens. It was exctracted
### and sent to me.

# Loading data from the MySQL database
library(sqldf)

# Creating a connection
db <- dbConnect(MySQL(), user='root', dbname='ocha_sissh', host='localhost')

# Getting a list of tables.
table_list <- dbListTables(db)

# Reading all the tables as data.frames into R
rt <- function(name) { 
        df <- dbReadTable(db, name)
        df
} 

# Loading the tables into separate data.frames.
# Encoding is challenging here.
categoria <- rt(table_list[1])  # done
contacto <- rt(table_list[2])  # done
dato_sector <- rt(table_list[3])  # done
depto_dato <- rt(table_list[4])  # done
mpio_dato <- rt(table_list[5])  # done
sector <- rt(table_list[6])  # done
total_deptal_valor_dato <- rt(table_list[7])
total_nacional_valor_dato <- rt(table_list[8])
unidad_dato <- rt(table_list[9])  # done

# Tidy.
dbDisconnect(mydb)

# Trying to fix encoding.
source('fix_encoding.R')
categoria <- fixEncoding(df = categoria)
contacto <- fixEncoding(df = contacto)
dato_sector <- fixEncoding(df = dato_sector)  # error
depto_dato <- fixEncoding(df = depto_dato)
mpio_dato <- fixEncoding(df = mpio_dato)
sector <- fixEncoding(df = sector)
total_deptal_valor_dato <- fixEncoding(df = total_deptal_valor_dato)
total_nacional_valor_dato <- fixEncoding(df = total_nacional_valor_dato)
unidad_dato <- fixEncoding(df = unidad_dato)

# loading value table from CSV
valor_dato <- read.csv('data/valor_dato.csv')

## Organizing the data.frames for clearer analysis.
## Adding the unit labels.
municipal_data <- merge(mpio_dato, dato_sector, by = "ID_DATO", all = TRUE)
municipal_data$geo <- 'Admin 3'
departamental_data <- merge(depto_dato, dato_sector, by = "ID_DATO", all = TRUE)
departamental_data$geo <- 'Admin 2'
all_data <- plyr::rbind.fill(departamental_data, municipal_data)


# Adding labels
# x <- all_data
all_data <- merge(all_data, unidad_dato, by = 'ID_UNIDAD')
all_data$ID_UNIDAD <- NULL
all_data$ID_DATO <- NULL
all_data <- merge(all_data, categoria, by = 'ID_CATE')
all_data$ID_CATE <- NULL
all_data$ID_COMP.y <- NULL
all_data <- merge(all_data, sector, by = 'ID_COMP')
all_data$ID_COMP <- NULL


# x <- valor_dato
value <- merge(valor_dato, indicator, by = 'ID_DATO', all.x = TRUE)
value$ID_UNIDAD <- NULL  # I don't know what is this
value$ID_VALDA <- NULL  # I don't know what is this
value$ID_DATO <- NULL  # Not necessary anymore.
value$ID_POB <- NULL  # All values are NULL.
colnames(value)[5] <- 'value'
value$units <- NULL
value$name <- NULL
value$NOM_UNIDAD <- NULL

# Checking what date to put the observation on.
value$exten <- as.Date(value$FIN_VALDA) - as.Date(value$INI_VALDA)
value$id <- 1:nrow(value)  # ading and id column

## making a list of factors ##
time_factor_list <- data.frame(summary(as.factor(value$exten)))
colnames(time_factor_list)[1] <- 'count'
write.csv(time_factor_list, 'temp.csv')
time_factor_list <- read.csv('temp.csv')
colnames(time_factor_list)[1] <- 'days'
time_factor_list$days <- as.numeric(as.character(time_factor_list$days))
time_factor_list$n_years <- round((time_factor_list$days / 364), 1)
time_factor_list$percentage <- round(((time_factor_list$count / nrow(value)) * 100), 1)

# adding categories # 
time_factor_list$category <- 'daily'
time_factor_list$category[2:8] <- 'biannual'
time_factor_list$category[9:14] <- 'yearly'
time_factor_list$category[15:19] <- 'multi-year'
time_factor_list$category[20] <- NA

write.csv(time_factor_list, 'time_factor_list.csv', row.names = F)

## using the time_factor_list to sort the value table
value$n_years <- round((value$exten / 364), 1)
value <- merge(value, time_factor_list, by = 'n_years', all.x = TRUE)
value$percentage <- NULL
value$count <- NULL

## Adding the time observations based on categories ##
value$period <- ifelse(value$category == 'daily', paste(value$FIN_VALDA), value$period)
value$period <- ifelse(value$category == 'biannual', paste(value$INI_VALDA, value$FIN_VALDA, sep = '/'), value$period)
value$period <- ifelse(value$category == 'yearly', format(as.Date(value$FIN_VALDA), format = "%Y"), value$period)
value$period <- ifelse(value$category == 'multi-year', 
            paste(format(as.Date(value$INI_VALDA), format = "%Y"),
                  format(as.Date(value$FIN_VALDA), format = "%Y"),
                  sep = '-'), 
            value$period)

# combining the pvalue column
value$region <- ifelse(is.na(value$ID_MUN), value$ID_DEPTO, value$ID_MUN)

# Cleaning
value$n_years <- NULL
value$id <- NULL
value$ID_MUN <- NULL
value$ID_DEPTO <- NULL
value$INI_VALDA <- NULL
value$FIN_VALDA <- NULL
value$exten <- NULL
value$days <- NULL
value$category <- NULL


# adding the cols to the pcolumn # 
value <- CPSify(df = a, iso3 = 'COL')

##########################
##########################
#### Adapting to CPS. ####
##########################
##########################

# indicator
ind_data <- dato_sector[dato_sector$ID_DATO == unique(dato_sector$ID_DATO), ]
indicator <- data.frame(ind_data$ID_DATO, ind_data$NOM_DATO, ind_data$ID_UNIDAD)
names(indicator) <- c('ID_DATO', 'name', 'units')
indicator <- merge(indicator, unidad_dato, by.x = 'units', by.y = 'ID_UNIDAD', all.x = TRUE)
# Coding automatically the CHD
source('code/chd_coder.R')
indicator <- chdCoder(iso3 = 'COL')
indicator <- fixEncoding(indicator)
indicator$ID_DATO <- NULL
names(indicator) <- c('name', 'units', 'indID')

# Translating the units into English.
translateUnits <- function() {
    library(translate)
    units <- list()
    pb <- txtProgressBar(min = 0, max = nrow(indicator), style = 3)    
    for (i in 1:nrow(indicator)) {
        setTxtProgressBar(pb, i)
        units[i] <- translate(as.character(indicator$units[i]), 
                      'es', 'en', key = gtrans_auth)
    }
 return(units)   
}
indicator$units <- translateUnits()

# eliminating lists in data.frame (otherwise won't export CSV)
indicator$units <- as.character(indicator$units)
indicator$indID<- as.character(indicator$indID)


# dataset
dsID <- 'ocha_colombia_sidih'
last_updated <- Sys.time()
last_scraped <- Sys.time()
name <- 'OCHA Sistema Integrado de Información Humanitaria para Colombia'
dataset <- data.frame(dsID, last_updated, last_scraped, name)

# value
# all_data <- merge(all_data, indicator, by.x = 'NOM_DATO', by.y = 'name', all = TRUE)
# here we are using the p-codes provided by DANE / OCHA
value$dsID <- dataset$dsID[1]
value$source <- 'http://sidih.salahumanitaria.co'
value$value_true <- 1
value$value_false <- 0
value$is_number <- ifelse(is.numeric(value$value), value$value_true, value$value_false)
value$value_true <- NULL
value$value_false <- NULL



### Writing the CSV files. 
write.csv(indicator, 'data/cps/indicator.csv', row.names = F)
x <- na.omit(value)  # aparently the value is coming with a few NAs -- check!
write.csv(x, 'data/cps/value.csv', row.names = F)
write.csv(dataset, 'data/cps/dataset.csv', row.names = F)
source('code/create_configuration.R')
createConfiguration(src = 'ocha_colombia_sidih')
