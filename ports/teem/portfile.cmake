vcpkg_download_distfile(
    ARCHIVE
    URLS "https://sourceforge.net/projects/teem/files/teem/1.11.0/teem-1.11.0-src.tar.gz/download"
    FILENAME "teem-1.11.0-src.tar.gz"
    SHA512 48b171a12db0f02dcfdaa87aa84464c651d661fa66201dc966b3cd5a8134c5bad1dad8987ffcc5d7c21c5d14c2eb617d48200410a1bda19008ef743c093ed575
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Apply patches to CMakeLists.txt
file(READ "${SOURCE_PATH}/CMakeLists.txt" _contents)

# Patch 1: Fix cmake version
string(REGEX REPLACE "cmake_minimum_required\\(VERSION [^\\)]+\\)" "cmake_minimum_required(VERSION 3.5)" _contents "${_contents}")

# Patch 2: remove EXPORT_LIBRARY_DEPENDENCIES (deprecated)
string(REGEX REPLACE "[ \t]*EXPORT_LIBRARY_DEPENDENCIES\\(.*\\)[ \t]*\r?\n" "" _contents "${_contents}")

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${_contents}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0077=NEW
)

vcpkg_cmake_install()

# Install headers manually since CMake install may not work correctly
# Teem consists of multiple libraries, so install headers from all modules
set(TEEM_MODULES air biff hest nrrd ell unrrdu dye gage hoover limn echo ten pull coil push seek mite meet)

foreach(MODULE ${TEEM_MODULES})
    # Look for headers in each module directory
    file(GLOB MODULE_HEADERS "${SOURCE_PATH}/src/${MODULE}/*.h")
    if(MODULE_HEADERS)
        file(INSTALL ${MODULE_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/teem")
    endif()
endforeach()

# Also install any main teem header if it exists
if(EXISTS "${SOURCE_PATH}/src/teem.h")
    file(INSTALL "${SOURCE_PATH}/src/teem.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/teem")
endif()

# Fallback: ensure at least the core headers are present
set(CORE_HEADERS
    "${SOURCE_PATH}/src/air/air.h"
    "${SOURCE_PATH}/src/biff/biff.h"
    "${SOURCE_PATH}/src/hest/hest.h"
    "${SOURCE_PATH}/src/nrrd/nrrd.h"
)

foreach(HEADER ${CORE_HEADERS})
    if(EXISTS "${HEADER}")
        file(INSTALL "${HEADER}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/teem")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")