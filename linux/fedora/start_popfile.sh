#!/bin/sh

popfile_root=/usr/share/popfile/
popfile_data=/var/lib/popfile/
popfile_piddir=/var/run/
popfile_logdir=/var/log/popfile/

PARAMS="--set config_piddir=${popfile_piddir} --set logger_logdir=${popfile_logdir}"

export POPFILE_ROOT=${popfile_root}
export POPFILE_USER=${popfile_data}

umask 0027
exec /usr/share/popfile/popfile.pl $PARAMS &> ${logdir}/console.log &

