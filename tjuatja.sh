#!/usr/bin/env bash

URL="http://data.bmkg.go.id/cuaca_indo_1.xml"
CITY="Semarang"
COND=""
TEMP=""
HUM=""

HELP="tjuatja.sh -

A simple program that provides weather information from the Indonesian Agency for Meteorological, Climatological and Geophysics (BMKG). Currently only supports major city in Indonesia.

Usage: tjuatja.sh -c -t -h CITY

	-c   Show condition (in Indonesian)
	-t   Show temperature (in Celcius)
	-h   Show humidity"

DATA=`wget -q -O- $URL`

getCondition () {
	city="$1"
	findwhat='''//Row[Kota='''\"$city\"''']/Cuaca/text()'''
	COND=`echo $DATA | tr -d "\n\r" | xmllint --xpath "$findwhat" -`
}
getTemperature () {
	city="$1"
	findwhat1='''//Row[Kota='''\"$city\"''']/SuhuMin/text()'''
	findwhat2='''//Row[Kota='''\"$city\"''']/SuhuMax/text()'''
	mintemp=`echo $DATA | tr -d "\n\r" | xmllint --xpath "$findwhat1" -`
	maxtemp=`echo $DATA | tr -d "\n\r" | xmllint --xpath "$findwhat2" -`
	TEMP=$((($mintemp + $maxtemp)/2))
}
getHumidity () {
	city="$1"
	findwhat1='''//Row[Kota='''\"$city\"''']/KelembapanMin/text()'''
	findwhat2='''//Row[Kota='''\"$city\"''']/KelembapanMax/text()'''
	minhum=`echo $DATA | tr -d "\n\r" | xmllint --xpath "$findwhat1" -`
	maxhum=`echo $DATA | tr -d "\n\r" | xmllint --xpath "$findwhat2" -`
	HUM=$((($minhum + $maxhum)/2))
}

unset name

while getopts cth name
do
	case $name in
		c)condOpt=1;;
		t)tempOpt=1;;
		h)humiOpt=1;;
		\?)
            echo "Usage: `basename $0` -h for help";
            echo "$HELP"
            exit $E_OPTERROR;
        ;;
	esac
done

shift $(($OPTIND -1))

if [[ ! -z $1 ]]
then
	CITY="$1"
fi

if [[ ! -z $condOpt ]]
then
	getCondition "$1"
fi
if [[ ! -z $tempOpt ]]
then
	getTemperature "$1"
fi
if [[ ! -z $humiOpt ]]
then
	getHumidity "$1"
fi

echo $COND $TEMP $HUM