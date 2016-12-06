#!/bin/bash
<<'COMMENT'
Saca lineas innecesarias de los logs antes de ser enviados via email
COMMENT
#
# sed -i '/org.apache.karaf.main/,/org.apache.cxf.endpoint.ServerImpl initDestination/d' $1
#
sed -i '/cfgbuilder/d' $1
exit
