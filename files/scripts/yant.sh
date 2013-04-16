#!/bin/bash
# yant.sh - Made for Puppi
# Sources common header for Puppi scripts
. $(dirname $0)/header || exit 10

# Show help
showhelp () {
    echo "This script is used to call ant in a hybris-system"
    echo "It requires AT LEAST 2 arguments:"
    echo "First the \${hybris_parent_dir} where it can find a hybris-directory"
    echo "Second argument: Everything you want to pass through to ant"
    echo "The script assumes that hybris is located in \${hybris_parent_dir}/hybris"
    echo
    echo "Examples:"
    echo "yant.sh /home/hybris clean all"
}

# Unfortunately, showhelp will never be called

hybrispath=$1/hybris
cd $hybrispath/bin/platform
. ./setantenv.sh

# somehow dirty ...
shift

if [ -d $hybrispath/config ]; then
	template=""
else
	template=-Dinput.template=develop 
fi

if [ $debug ] ; then
    ant -Dinput.template=develop $* > $hybrispath/bin/platform/ant.out
else
    ant -Dinput.template=production -DJAVAMEM=3G $* > $hybrispath/bin/platform/ant.out
fi

handle_result
