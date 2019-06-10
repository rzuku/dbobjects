 #!/bin/bash
 # get all db objects
 find . -name "*d?l.sql" |xargs cat |sed -e 's/^[\t ]*//g' -e 's/"//g' -e 's/\r//g'| egrep -i -e   '^insert|^update|^delete|^create|^alter|^drop|^merge|^grant|^revoke'  | tr [a-z] [A-Z] |tee -a tmp.txt|awk  '\
 {if ($1 == "CREATE" && $2 != "OR" && $2 !="UNIQUE" && $2 !="PUBLIC" ) { print $2","$3","$1 }\
 else if ( $1 == "CREATE" &&  $2 == "UNIQUE" ) { print $3","$4","$1 }\
 else if ( $1 == "CREATE" &&  $2 == "PUBLIC" ) { print $3","$4","$1 }\
 else if ($1 == "CREATE" && $2 == "OR" && $3 == "REPLACE" && $4 != "FORCE" && $5 != "BODY") { print $4","$5 } \
 else if ( $1 == "CREATE" && $2 == "OR" && $3 == "REPLACE" && $4 == "FORCE") { print $5","$6}\
 else if ( $1 == "CREATE" && $2 == "OR" && $3 == "REPLACE" && $5 == "BODY") { print $4","$6}\
 else if ($2 == "PUBLIC") { print $3","$4 } \
 else if ($1 == "INSERT" || $1 == "DELETE" || $1 == "MERGE") {print "TABLE\\VIEW,"$3 }\
 else if (($1 == "CREATE" && toupper($2) != "OR") || $1 == "ALTER" || ($1 == "DROP" && $2 != "PUBLIC" && $2 != "COLUMN")) \
 {print $2","$3}\
 else if ($1 == "UPDATE") { print  "TABLE,"$2  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 == "EXECUTE") { print  "FUNCTION\\PROCEDURE\\PACKAGE,"$4  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 != "EXECUTE" && $3 == "ON") { print  "TABLE\\VIEW,"$4  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 == "EXECUTE") { print  "FUNCTION\\PROCEDURE\\PACKAGE,"$4  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 != "EXECUTE" && $3 == "ON") { print  "TABLE\\VIEW,"$4  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 != "EXECUTE" && $3 != "ON") { print  "ZZZ TABLE\\VIEW,"$1","$2","$3","$4","$5","$6","$7","$8  } \
 else if (($1 == "GRANT" || $1 == "REVOKE") && $2 != "EXECUTE" && $3 != "ON") { print  "ZZZ TABLE\\VIEW,"$1","$2","$3","$4","$5","$6","$7","$8  } \
 }'|sort |uniq |awk -F\( '{ print $1}' |awk -F\; '{ print $1}' |sort |uniq >all.txt
 
 #objects with no doubt about its type
 cat all.txt |grep -v '^TABLE\\' |grep -v '^FUNCTION\\' >objects.txt
 
 # list with doubt re TABLE and VIEW
 cat all.txt |grep TABLE |grep VIEW |grep -v ZZZ >list.txt
 
 #select creation
 cat list.txt |awk -F, '{ print $2 }' |awk  -F. '{ if ($2) { print $2 } else { print $1 } }' |sort |uniq |awk 'NF { print $0 }          ' |xargs |sed -e "s/^/('/g" -e "s/ /','/g" -e "s/$/')/" >for_select.txt
 echo "select object_name,object_type from all_objects where object_name in " `cat for_select.txt` " and object_type in ('TABLE','VIEW') order by object_name asc;" >select.txt
 #select execution
 sqlplus $ORACLE_UID<select.txt |egrep -e "TABLE|VIEW" |awk '{ print $2","$1}' |sort >>objects.txt
 
 # list with doubt re FUNCTION and PROCEDURE
 cat all.txt |grep FUNCTION |grep PROCEDURE |grep -v ZZZ >list.txt
 
 #select creation
 cat list.txt |awk -F, '{ print $2 }' |awk  -F. '{ if ($2) { print $2 } else { print $1 } }' |sort |uniq |awk 'NF { print $0 }          ' |xargs |sed -e "s/^/('/g" -e "s/ /','/g" -e "s/$/')/" >for_select.txt
 echo "select object_name,object_type from all_objects where object_name in (" `cat for_select.txt` ")and object_type in ('FUNCTION','PROCEDURE','PACKAGE') order by object_name asc;" >select.txt
 #select execution
 sqlplus $ORACLE_UID<select.txt |egrep -e "FUNCTION|PROCEDURE|PACKAGE" |awk '{ print $2","$1}' |sort >>objects.txt
 
 #PPB sometimes was displayed as a prefix which was not necesarry. This is why I get rid of that.
 cat objects.txt |sed -e "s/^[\t ]*//g" -e "s/PPB\.//" |sort |uniq
