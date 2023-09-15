# Challenge 4: Catching up with photovoltaic expansion
Published pv installed capacity underestimates pv production. We want to estimate pv installed capacity considering pv growth patterns.

### Description
Pronovo is the entity that provides a very good overview of installed pv systems in Switzerland and many market players use the Pronovo database to estimate PV production. Unfortunately, there are major delays between the installation of the pv systems and the recording in the Pronovo database. This wasn't a bigger issue so far, but the swiss pv market is growing rapidly and so the lag is causing a general underestimation of pv power production.

With additional information on the pv systems such as installation date, audit date, date of entry into the database, we would like to identify patterns, trends and seasonalities in order to be able to better and continuously estimate the current status of the pv expansion.

Data:
https://drive.google.com/file/d/1LaHR35mKksVG_Df7v4XcKOhj8AX96QSu/view?usp=drive_link


### Data Description (only relevant features)
| Feature  Name                           	| Description                                	| Description2 	|
|-----------------------------------------	|--------------------------------------------	|--------------	|
| kev_nr                                  	| id                                         	| chr          	|
| auditdatum                              	| check if system exists                     	| dd.mm.yyyy   	|
| kev_ibm_formular_beg_datum              	| date formular reaches pronovo              	| dd.mm.yyyy   	|
| kev_ibm_meldung_komlpett_datum          	| date application is complete               	| dd.mm.yyyy   	|
| kev_zweitkontrolle_datum                	| date the pv sytem is registered at pronovo 	| dd.mm.yyyy   	|
| plz                                     	| zip code                                   	| int          	|
| ort                                     	| municipality                               	| chr          	|
| kanton                                  	| kanton                                     	| chr          	|
| land                                    	| coutntry                                   	| chr          	|
| realisierte_leistung_erstinbetriebnahme 	| first registered installed capacity in KW  	| float        	|
| realisierte_leistung_inkl_erweiterungen 	| actual registered installed capacity in KW 	| float        	|
| geplantes_inbetriebnahmedatum           	| planned putting into operation             	| dd.mm.yyyy   	|
| inbetriebnahme                          	| putted into operation                      	| dd.mm.yyyy   	|
