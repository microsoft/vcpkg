vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(
    ON_TARGET "OSX"
)

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF 636f507c33f0c79dce491aec066455ff384d49dc
    SHA512 3282876be5883b047e8d25ee392f62d2e9ae79af8fdd65c11b1e36d2fdb0648230fe6c7fb57472a4cbced166979351f12494215aa664977a113b74c26bb6f19b
    HEAD_REF master
)

set(CM_COMMIT_HASH fe41e86552046c3df9ba73a40bf3d755df028c1e)

# Get cmake scripts for c4core
vcpkg_download_distfile(CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${CM_COMMIT_HASH}.zip"
    FILENAME "cmake-${CM_COMMIT_HASH}.zip"
    SHA512 7292f9856d9c41581f2731e73fdf08880e0f4353b757da38a13ec89b62c5c8cb52b9efc1a9ff77336efa0b6809727c17649e607d8ecacc965a9b2a7a49925237
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

set(FF_COMMIT_HASH 8159e8bcf63c1b92f5a51fb550f966e56624b209)

vcpkg_download_distfile(FAST_FLOAT_ARCHIVE
    URLS "https://github.com/biojppm/fast_float/archive/${FF_COMMIT_HASH}.zip"
    FILENAME "fast_float-${FF_COMMIT_HASH}.zip"
    SHA512 ae71f74d3bae782f62f037c034bea4e7f45462188c8285971c2959c6b2884d3bb58826681c0989f4290f26fa33237c1b63ceed77ed94f9e97c1cd01b4aa21cd3
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
