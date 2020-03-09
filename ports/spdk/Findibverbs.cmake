# Find the ibverbs libraries
#
# The following variables are optionally searched for defaults
#  IBVERBS_ROOT_DIR: Base directory where all ibverbs components are found
#  IBVERBS_INCLUDE_DIR: Directory where ibverbs headers are found
#  IBVERBS_LIB_DIR: Directory where ibverbs libraries are found

# The following are set after configuration is done:
#  IBVERBS_FOUND
#  IBVERBS_INCLUDE_DIRS
#  IBVERBS_LIBRARIES

FIND_PATH(IBVERBS_INCLUDE_DIRS
          NAMES infiniband/verbs.h
          HINTS
          ${IBVERBS_INCLUDE_DIR}
          ${IBVERBS_ROOT_DIR}
          ${IBVERBS_ROOT_DIR}/include)

FIND_LIBRARY(IBVERBS_LIBRARIES
             NAMES ibverbs
             HINTS
             ${IBVERBS_LIB_DIR}
             ${IBVERBS_ROOT_DIR}
             ${IBVERBS_ROOT_DIR}/lib)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ibverbs DEFAULT_MSG IBVERBS_INCLUDE_DIRS IBVERBS_LIBRARIES)
MARK_AS_ADVANCED(IBVERBS_INCLUDE_DIR IBVERBS_LIBRARIES)

IF (NOT IBVERBS_LIBRARIES)
    SET(IBVERBS_FOUND FALSE)
    MESSAGE(FATAL_ERROR "ibverbs library not found.\nTry: 'sudo yum install libibverbs-devel  libibverbs' (or sudo apt-get install libibverbs-dev  libibverbs1)")
ENDIF ()
