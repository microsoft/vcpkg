INCLUDE(FindPackageHandleStandardArgs)

FIND_PATH(NUMA_ROOT_DIR
          NAMES include/numa.h
          PATHS ENV NUMA_ROOT
          DOC "NUMA library root directory")

FIND_PATH(NUMA_INCLUDE_DIR
          NAMES numa.h
          HINTS ${NUMA_ROOT_DIR}
          PATH_SUFFIXES include
          DOC "NUMA include directory")

FIND_LIBRARY(NUMA_LIBRARY
             NAMES numa
             HINTS ${NUMA_ROOT_DIR}
             DOC "NUMA library file")

IF (NUMA_LIBRARY)
    GET_FILENAME_COMPONENT(NUMA_LIBRARY_DIR ${NUMA_LIBRARY} PATH)
    MARK_AS_ADVANCED(NUMA_INCLUDE_DIR NUMA_LIBRARY_DIR NUMA_LIBRARY)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(NUMA REQUIRED_VARS NUMA_ROOT_DIR NUMA_INCLUDE_DIR NUMA_LIBRARY)
ELSE ()
    SET(NUMA_FOUND FALSE)
    MESSAGE(FATAL_ERROR "Numa library not found.\nTry: 'sudo yum install numactl numactl-devel' (or sudo apt-get install libnuma1 libnuma-dev)")
ENDIF ()
