#library(tidyverse)
library(openxlsx)
library(janitor)
#library(janitor)
library(tidyverse)
library(lubridate)

# read excel
anlagen <- read.xlsx("C:/Users/Z40ALTO/Downloads/20230901_PRODUKTIONSEINHEITEN_739725.xlsx", "Report", startRow = 3)
anlagen <- clean_names(anlagen)
anlagen$kev_nr <- as.numeric(anlagen$kev_nr)



#read csv

audits <- read.csv("C:/Users/Z40ALTO/Downloads/pronovo audit.csv", sep = ";")
audits <- clean_names(audits)
names(audits)[1] <- c("kev_nr")

pv_anlagen <- anlagen[anlagen$technologie_code == "Photovoltaic",]
##
#pv_anlagen <- pv_anlagen[pv_anlagen$anlagenstatus_kev == "EIV abgerechnet",]
##



df <- merge(audits, pv_anlagen, by="kev_nr", all=TRUE)

df$name_der_produktionsanlage <- NULL
df$adresszeile_1_strasse_nr <- NULL
df$adresszeile_2_z_b_postfach <- NULL
df$name_des_betreibers <- NULL
df$adresszeile_1_strasse_nr_2 <- NULL
df$adresszeile_2_z_b_postfach_2 <- NULL
df$firmenzusatz <- NULL

df <- df[df$anlagenstatus_kev=="EIV abgerechnet",]

df$geplantes_inbetriebnahmedatum <- convertToDateTime(df$geplantes_inbetriebnahmedatum, origin = "1900-01-01")
df$inbetriebnahme <- convertToDateTime(df$inbetriebnahme, origin = "1900-01-01")

df$gultig_von <- convertToDateTime(df$gultig_von, origin = "1900-01-01")
df$gultig_von_2 <- convertToDateTime(df$gultig_von_2, origin = "1900-01-01")
df$gultig_von_3 <- convertToDateTime(df$gultig_von_3, origin = "1900-01-01")
df$gultig_von_4 <- convertToDateTime(df$gultig_von_4, origin = "1900-01-01")
df$gultig_von_5 <- convertToDateTime(df$gultig_von_5, origin = "1900-01-01")
df$gultig_von_6 <- convertToDateTime(df$gultig_von_6, origin = "1900-01-01")
df$gultig_von_7 <- convertToDateTime(df$gultig_von_7, origin = "1900-01-01")
df$gultig_von_8 <- convertToDateTime(df$gultig_von_8, origin = "1900-01-01")

df$gultig_bis <- convertToDateTime(df$gultig_bis, origin = "1900-01-01")
df$gultig_bis_2 <- convertToDateTime(df$gultig_bis_2, origin = "1900-01-01")
df$gultig_bis_3 <- convertToDateTime(df$gultig_bis_3, origin = "1900-01-01")
df$gultig_bis_4 <- convertToDateTime(df$gultig_bis_4, origin = "1900-01-01")
df$gultig_bis_5 <- convertToDateTime(df$gultig_bis_5, origin = "1900-01-01")
df$gultig_bis_6 <- convertToDateTime(df$gultig_bis_6, origin = "1900-01-01")
df$gultig_bis_7 <- convertToDateTime(df$gultig_bis_7, origin = "1900-01-01")
df$gultig_bis_8 <- convertToDateTime(df$gultig_bis_8, origin = "1900-01-01")

df <- select(df, "kev_nr",
               "inbetriebnahme",
               "auditdatum",
               "kev_ibm_formular_beg_datum",
               "kev_ibm_meldung_komlpett_datum",         
               "kev_zweitkontrolle_datum",
               "plz",
               "kanton", 
               "name_netzbetreiber",
               "realisierte_leistung_inkl_erweiterungen")  

df$auditdatum <- as.Date(strptime(df$auditdatum, format = "%d.%m.%Y"))

df$kev_ibm_formular_beg_datum <- as.Date(strptime(df$kev_ibm_formular_beg_datum, format = "%d.%m.%Y"))

df$kev_ibm_meldung_komlpett_datum <- as.Date(strptime(df$kev_ibm_meldung_komlpett_datum, format = "%d.%m.%Y"))

df$kev_zweitkontrolle_datum <- as.Date(strptime(df$kev_zweitkontrolle_datum, format = "%d.%m.%Y"))

df <- df[!is.na(df$kev_nr),]
df <- df[!is.na(df$inbetriebnahme),]

df$name_netzbetreiber <- gsub(",","_",df$name_netzbetreiber)

write.csv(df,"C:/Users/Z40ALTO/Documents/GitHub/EnergyDataHackdays2023-PV_Expansion/data/oehd_pronovo2.csv", row.names = FALSE, quote = FALSE, fileEncoding="UTF-8")

####

### aggregate values ###
df_aggr <- read.csv("C:/Users/Z40ALTO/Documents/GitHub/EnergyDataHackdays2023-PV_Expansion/data/oehd_pronovo2.csv")
df_aggr$inbetriebnahme <- as.Date(df_aggr$inbetriebnahme)
df_aggr$floor_date <- floor_date(df_aggr$inbetriebnahme, "month")

monthly_data <- aggregate(realisierte_leistung_inkl_erweiterungen ~ floor_date + kanton, df,FUN = sum)
#monthly_data <- select(df_aggr, floor_date, kanton, realisierte_leistung_inkl_erweiterungen)

monthly_wide <- monthly_data %>% 
  pivot_wider(names_from = kanton, values_from = realisierte_leistung_inkl_erweiterungen)

monthly_wide <- monthly_wide %>% replace(is.na(.), 0)

monthly_wide$floor_date <- floor_date(monthly_wide$floor_date, "month")
names(monthly_wide)[1] <- c("date")
monthly_wide$date <- as.Date(monthly_wide$date)
monthly_wide$date <- floor_date(monthly_wide$date, "month")

sfoe2 <- select(sfoe, date, SFOE)

monthly_wide <- merge(sfoe2, monthly_wide, by="date", all = TRUE)
monthly_wide <- monthly_wide %>% replace(is.na(.), 0)


B <- monthly_wide[,-c(1:2)]
B[] <- lapply(B, cumsum)

B <- B/1000

monthly_cum <- cbind(monthly_wide[,c(1:2)], B)

monthly_cum <- monthly_cum[monthly_cum$date >= "2015-01-01" & monthly_cum$date <= "2023-01-01",]

write.csv(monthly_cum,"C:/Users/Z40ALTO/Documents/GitHub/EnergyDataHackdays2023-PV_Expansion/data/monthly_cumulative_installed_capacity_cantons.csv", row.names = FALSE, quote = FALSE, fileEncoding="UTF-8")


##### ML Part ######

#Split 80/20 train 2017-2020 and test 2021
df_train <- monthly_cum[monthly_cum$date<=as.Date("2021-08-01"),]
df_train <- df_train[,2:28]

df_test <- monthly_cum[monthly_cum$date>as.Date("2021-08-01"),]
df_models <- df_test

# exclude unique var date
df_test <- df_test[,2:28]

####### LINEAR MODEL########
# Fit lm model on train
model<-lm(SFOE~. + ZH^2 + BE^2 + UR^2 + SZ^2 + GE^2,df_train)

# Predict on test
df_models$lm_prediction<-predict(model,df_test)

# RMSE
error <- df_models$lm_prediction-df_models$SFOE  
rmse_lm <- round(sqrt(mean(error^2)),2)

summary(lm(SFOE ~ ., df_train))   








###
library(plotly)
p_pv <- plot_ly(df_models, x = ~date, y = ~SFOE, type = 'scatter',mode="lines", name = 'statistical values')%>% 
  add_trace(y = ~lm_prediction, type = 'scatter',  mode = 'lines', name = 'estimate') %>%
  #add_trace(y = ~nn_prediction, type = 'scatter',  mode = 'lines', name = 'Neural Network') %>%
  layout(title =  paste("RMSE LM =", rmse_lm) ,xaxis = list(title = ""),yaxis = list(title = "cum sum installed capacity") )
p_pv

###


df2 <- read.csv("C:/Users/Z40ALTO/Downloads/installed_capacity_sfoe.csv", sep=";")
library(tidyverse)
test <- select(df2, ï..Begin, "SFOE", "EQ", "Estimate")
test$SFOE <- round(test$SFOE, 1)
test$ï..Begin <- as.Date(strptime(test$ï..Begin, format = "%d.%m.%Y"))
names(test)[1] <- c("date")
sfoe <- test
write.csv(test,"C:/Users/Z40ALTO/Documents/GitHub/EnergyDataHackdays2023-PV_Expansion/data/installed_capacity_SFOE.csv", row.names = FALSE, quote = FALSE, fileEncoding="UTF-8")

plot(x=test$ï..Begin, y)


#####

pronovo <- select(df, 
                  inbetriebnahme,
                  auditdatum, 
                  kev_ibm_formular_beg_datum, 
                  kev_ibm_meldung_komlpett_datum,
                  plz,
                  kanton,
                  realisierte_leistung_inkl_erweiterungen)

day1 <- as.Date("2018-01-01")
test <- pronovo[pronovo$inbetriebnahme>day1,]

