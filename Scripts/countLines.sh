#!/bin/bash
<<COMMENT
Cuenta la cantidad de lineas que tiene el archivo a procesar
PARAMS: Nombre completo del archivo e.j. /calidad/NokiaAluIPRAN/xml_output/201611161307_CardStatus_xml.csv
COMMENT
#
wc -l < $1
