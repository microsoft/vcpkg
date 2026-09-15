# MSVC is not supported by the upstream project.
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    message(FATAL_ERROR "FuzzTest requires Clang or GCC. MSVC is not supported.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/fuzztest
    REF "${VERSION}"
    SHA512 dcfd1596286ee1bdaba654d6b291d048718610b10de5aca09982fd6297f9233826aad81f9ae06a56a5cdeaf67d540c2b4a3145a31a42009772466bc997d321eb
    HEAD_REF main
    PATCHES
        patches/vcpkg.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/fuzztest-config.cmake.in"
    DESTINATION "${SOURCE_PATH}/cmake")

set(RE2_REF "927f5d53caf8111721e734cf24724686bb745f55")
vcpkg_download_distfile(RE2_ARCHIVE
    URLS "https://github.com/google/re2/archive/${RE2_REF}.tar.gz"
    FILENAME "re2-${RE2_REF}.tar.gz"
    SHA512 35103a46a6350084f2d09ccfcf4322dac7364c61fbdad8bfcbd41b39990f83a260d2a8cd5ca019a3f24b71faf1588c7dabf07c3dddae5268bcc5b9502b87658a
)

set(RE2_EXTRACT_DIR "${CURRENT_BUILDTREES_DIR}/re2-vendor")
file(REMOVE_RECURSE "${RE2_EXTRACT_DIR}")
file(ARCHIVE_EXTRACT INPUT "${RE2_ARCHIVE}" DESTINATION "${RE2_EXTRACT_DIR}")

file(GLOB RE2_SRC_DIR "${RE2_EXTRACT_DIR}/re2-*")
file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/re2"
    "${SOURCE_PATH}/third_party/util")
file(COPY "${RE2_SRC_DIR}/re2/prog.h"
    "${RE2_SRC_DIR}/re2/regexp.h"
    "${RE2_SRC_DIR}/re2/pod_array.h"
    "${RE2_SRC_DIR}/re2/sparse_array.h"
    "${RE2_SRC_DIR}/re2/sparse_set.h"
    DESTINATION "${SOURCE_PATH}/third_party/re2")
file(COPY "${RE2_SRC_DIR}/util/utf.h"
    DESTINATION "${SOURCE_PATH}/third_party/util")

set(FUZZTEST_FEATURE_OPTIONS "")
if("flatbuffers" IN_LIST FEATURES)
    list(APPEND FUZZTEST_FEATURE_OPTIONS "-DFUZZTEST_BUILD_FLATBUFFERS=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DFUZZTEST_BUILD_TESTING=OFF
        -DFUZZTEST_FUZZING_MODE=OFF
        ${FUZZTEST_FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES grammar_domain_code_generator AUTO_CLEAN)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/fuzztest")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/centipede/dso_example"
    "${CURRENT_PACKAGES_DIR}/include/centipede/tools"
    "${CURRENT_PACKAGES_DIR}/include/fuzztest/grammars"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
