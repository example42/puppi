#!/bin/bash

# report_mongodb.sh - Made for Puppi
# This script sends a summary to a mongodb defined in $1
# e.g. somemongohost/dbname

# Sources common header for Puppi scripts
. $(dirname $0)/header || exit 10


fqdn=$(facter fqdn)

environment=$(facter environment -p)

mongodb=$1
result=$(grep result $logdir/$project/$tag/summary | awk '{ print $NF }')
summary=$(cat $logdir/$project/$tag/summary)

mcmd="db.deployments.insert({ts:new Date(),result:\"${result}\",fqdn:\"${fqdn}\",project:\"${project}\",source:\"${source}\",tag:\"${tag}\",version:\"${version}\",artifact:\"${artifact}\",testmode:\"${testmode}\",warfile:\"${warfile}\",environment:\"${environment}\"}); quit(0)"


mongo $mongodb --eval "$mcmd"

# Now do a reporting to enable "most-recent-versions on all servers"

read -r -d '' mcmd <<'EOF'
var map = function() {
  project=this.project ;
  emit( this.fqdn +":"+ this.project,  {project:this.project, fqdn:this.fqdn, ts:this.ts,version:this.version,environment:this.environment}  );
};
var reduce = function(k,vals) {
  result = vals[0];
  vals.forEach(function(val) { if (val.ts > result.ts) result=val } ) ;
  return result;
};
db.deployments.mapReduce(
  map,
  reduce,
  {out:{replace:"versions"}})
EOF

mongo $mongodb --eval "$mcmd"
