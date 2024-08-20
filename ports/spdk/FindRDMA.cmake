FIND_PATH(RDMA_INCLUDE_DIR rdma/rdma_cma.h
          /usr/include
          /usr/include/linux
          /usr/local/include
          )

FIND_LIBRARY(RDMA_LIBRARY NAMES rdmacm
             PATHS
             /usr/lib
             /usr/local/lib
             /usr/lib64
             /usr/local/lib64
             /lib/i386-linux-gnu
             /lib/x86_64-linux-gnu
             /usr/lib/x86_64-linux-gnu
             )

INCLUDE(FindPackageHandleStandardArgs)
IF (APPLE)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(RDMA DEFAULT_MSG
                                      RDMA_INCLUDE_DIR)
ELSE ()
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(RDMA DEFAULT_MSG
                                      RDMA_LIBRARY RDMA_INCLUDE_DIR)
ENDIF ()

MARK_AS_ADVANCED(RDMA_INCLUDE_DIR RDMA_LIBRARY)

IF (NOT RDMA_LIBRARY)
    SET(RDMA_FOUND FALSE)
    MESSAGE(FATAL_ERROR "RDMA library not found.\nTry: 'sudo yum install librdmacm-devel librdmacm' (or sudo apt-get install librdmacm-dev librdmacm1)")
ENDIF ()
