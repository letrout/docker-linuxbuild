#!/bin/bash

LINUX_VER=4.16.1
BASE_DIR=/kernel
RESULTS_DIR=${BASE_DIR}
LINUX_TARBALL=linux-${LINUX_VER}.tar.xz
LINUX_SRC_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/${LINUX_TARBALL}

# Files to store output
RESULTS_FILE="results_`date +%Y%m%d%H%M%S`.txt"
UNTAR_STATS="untar_out.txt"
CONFIG_STATS="config_out.txt"
CLEAN_PREBUILD_STATS="make_clean_prebuild.txt"
MAKE_STATS="make_out.txt"
CLEAN_POSTBUILD_STATS="make_clean_postbuild.txt"
REMOVE_STATS="remove_src.txt"

# Get the disk that BASE_DIR is mounted on
DISK=`awk -v needle="${BASE_DIR}" '$2==needle {print $1}' /proc/mounts |cut -d '/' -f 3`
DISKSTATS="grep ${DISK} /proc/diskstats"
PROCS_AVAIL=`getconf _NPROCESSORS_ONLN`
MAKE_J=${PROCS_AVAIL}

date > ${RESULTS_DIR}/${RESULTS_FILE}
echo "${PROCS_AVAIL} processes" >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "${MAKE_J} processes used for make -j" >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}

 # Get the source
mkdir -p ${BASE_DIR} \
 && wget ${LINUX_SRC_URL} -O ${BASE_DIR}/${LINUX_TARBALL}
cd ${BASE_DIR}

# untar
echo "untar kernel" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time tar -xf ${LINUX_TARBALL}) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}
cd linux-${LINUX_VER}

# Make the config
echo "make oldconfig" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time yes '' | make oldconfig) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}

# Make clean before build
echo "make clean before build" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time make clean) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}

# Make
echo "make -j ${MAKE_J} the kernel" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time make -j ${MAKE_J}) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}

# Make clean after build
echo "make clean after build" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time make clean) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
echo "" >> ${RESULTS_DIR}/${RESULTS_FILE}

# Remove the source
cd /
echo "remove source directory" >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}
(time rm -rf  ${BASE_DIR}/linux-${LINUX_VER}) 2>&1 >/dev/null | grep -A2 ^real >> ${RESULTS_DIR}/${RESULTS_FILE}
${DISKSTATS} >> ${RESULTS_DIR}/${RESULTS_FILE}