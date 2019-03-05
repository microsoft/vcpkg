include("${CMAKE_CURRENT_LIST_DIR}/LibLZMATargets.cmake")

set(LIBLZMA_LIBRARIES LibLZMA::LibLZMA)
get_filename_component(LIBLZMA_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../include" ABSOLUTE)

if(LIBLZMA_INCLUDE_DIR AND EXISTS "${LIBLZMA_INCLUDE_DIR}/lzma/version.h")
    file(STRINGS "${LIBLZMA_INCLUDE_DIR}/lzma/version.h" LIBLZMA_HEADER_CONTENTS REGEX "#define LZMA_VERSION_[A-Z]+ [0-9]+")

    string(REGEX REPLACE ".*#define LZMA_VERSION_MAJOR ([0-9]+).*" "\\1" LIBLZMA_VERSION_MAJOR "${LIBLZMA_HEADER_CONTENTS}")
    string(REGEX REPLACE ".*#define LZMA_VERSION_MINOR ([0-9]+).*" "\\1" LIBLZMA_VERSION_MINOR "${LIBLZMA_HEADER_CONTENTS}")
    string(REGEX REPLACE ".*#define LZMA_VERSION_PATCH ([0-9]+).*" "\\1" LIBLZMA_VERSION_PATCH "${LIBLZMA_HEADER_CONTENTS}")

    set(LIBLZMA_VERSION_STRING "${LIBLZMA_VERSION_MAJOR}.${LIBLZMA_VERSION_MINOR}.${LIBLZMA_VERSION_PATCH}")
    unset(LIBLZMA_HEADER_CONTENTS)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibLZMA  REQUIRED_VARS  LIBLZMA_LIBRARIES
                                                          LIBLZMA_INCLUDE_DIR
                                           VERSION_VAR    LIBLZMA_VERSION_STRING
                                 )
mark_as_advanced( LIBLZMA_INCLUDE_DIR LIBLZMA_LIBRARIES )