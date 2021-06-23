vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(
    ON_ARCH "arm" "arm64"
    ON_TARGET "OSX"
)

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF 2413e420fca270c20dfb7a962979d44e0d4c0337
    SHA512 2b5877941a5a4bdac625d7c54fc2f0e54eea3ab0d7487d314fde29abf441fcd70ed60598b9c8614c2993a7152a508b9ab9b7b234a777d138d5142e1a9df4c023
    HEAD_REF master
)

set(CM_COMMIT_HASH 71c211187b8c52a13d5c59a7979f2ccf8429e350)

# Get cmake scripts for c4core
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${CM_COMMIT_HASH}.zip"
    FILENAME "cmake-${CM_COMMIT_HASH}.zip"
    SHA512 d15884d985a477df47ead9c5c486cfdeb1df8b6de4f308c36bd7a8c0e901fb876980a2a4f239abd8ecb1fb0baf75ad559ca0780b50c84070762f8cbfe55cb9d2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH_CMAKE
    ARCHIVE ${CMAKE_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME ${SOURCE_PATH_CMAKE} "${SOURCE_PATH}/cmake")

set(DB_COMMIT_HASH 78e525c6e74df6d62d782864a52c0d279dcee24f)

vcpkg_download_distfile(DEBUGBREAK_ARCHIVE
    URLS "https://github.com/biojppm/debugbreak/archive/${DB_COMMIT_HASH}.zip"
    FILENAME "debugbreak-${DB_COMMIT_HASH}.zip"
    SHA512 25f3d45b09ce362f736fac0f6d6a6c7f2053fec4975b32b0565288893e4658fd0648a7988c3a5fe0e373e92705d7a3970eaa7cfc053f375ffb75e80772d0df64
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH_DEBUGBREAK
    ARCHIVE ${DEBUGBREAK_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/debugbreak")
file(RENAME ${SOURCE_PATH_DEBUGBREAK} "${SOURCE_PATH}/src/c4/ext/debugbreak")

set(FF_COMMIT_HASH 3377facde283d36fa3bd29080f46fb0589b74bd3)

vcpkg_download_distfile(FAST_FLOAT_ARCHIVE
    URLS "https://github.com/biojppm/fast_float/archive/${FF_COMMIT_HASH}.zip"
    FILENAME "fast_float-${FF_COMMIT_HASH}.zip"
    SHA512 e2a7b869e422113b099f2ab95e42de8aed3b13f961fdc84583a908159936fdad00990ce664bc0c2491b7ca49e3323e17fb08f2208b2ceb577015c7d89cc4d785
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH_FAST_FLOAT
    ARCHIVE ${FAST_FLOAT_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/fast_float")
file(RENAME ${SOURCE_PATH_FAST_FLOAT} "${SOURCE_PATH}/src/c4/ext/fast_float")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/c4core)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/c4core)
endif()

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" "${_contents}")

# Fix path to header
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/c4/error.hpp" "<debugbreak/debugbreak.h>" "\"extern/debugbreak/debugbreak.h\"")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
