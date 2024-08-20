vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF "v${VERSION}"
    SHA512 23e45d186d03a64701376fbb63b5e3608dfdac7188eefd869976e97149ee772c7547e460b305c938650a721eac0c0573b70b5a5a2cd7211192cf9c87f019548c
    HEAD_REF master
)

set(CM_COMMIT_HASH fe41e86552046c3df9ba73a40bf3d755df028c1e)

# Get cmake scripts for c4core
vcpkg_download_distfile(
    CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${CM_COMMIT_HASH}.zip"
    FILENAME "cmake-${CM_COMMIT_HASH}.zip"
    SHA512 7292f9856d9c41581f2731e73fdf08880e0f4353b757da38a13ec89b62c5c8cb52b9efc1a9ff77336efa0b6809727c17649e607d8ecacc965a9b2a7a49925237
)

vcpkg_extract_source_archive(
    SOURCE_PATH_CMAKE
    ARCHIVE ${CMAKE_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${SOURCE_PATH_CMAKE}" "${SOURCE_PATH}/cmake")

set(DB_COMMIT_HASH 5dcbe41d2bd4712c8014aa7e843723ad7b40fd74)

vcpkg_download_distfile(
    DEBUGBREAK_ARCHIVE
    URLS "https://github.com/biojppm/debugbreak/archive/${DB_COMMIT_HASH}.zip"
    FILENAME "debugbreak-${DB_COMMIT_HASH}.zip"
    SHA512 a4735225058b48031e68c91853c71d3cc31c8f2bfc3592cfc7a9a16f406224a814535ecade81ab4ead76458eeab8752e7e7cd521d893db5791dd4aaac3ba20d9
)

vcpkg_extract_source_archive(
    SOURCE_PATH_DEBUGBREAK  
    ARCHIVE ${DEBUGBREAK_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/debugbreak")
file(RENAME "${SOURCE_PATH_DEBUGBREAK}" "${SOURCE_PATH}/src/c4/ext/debugbreak")

set(FF_COMMIT_HASH 052975dd5f8166d0f9e4a215fa75a349d5985b91)

vcpkg_download_distfile(
    FAST_FLOAT_ARCHIVE
    URLS "https://github.com/biojppm/fast_float/archive/${FF_COMMIT_HASH}.zip"
    FILENAME "fast_float-${FF_COMMIT_HASH}.zip"
    SHA512 af63cbf1d6620cda87a5f0ca06dcaf46ddfe63658ae5ba91232a2416e8179cba3b2b3d06ff53c1ab2ba3745ae39b0cb787e04be3a9dbe1287605704c2ed13019
)

vcpkg_extract_source_archive(
    SOURCE_PATH_FAST_FLOAT 
    ARCHIVE ${FAST_FLOAT_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/fast_float")
file(RENAME "${SOURCE_PATH_FAST_FLOAT}" "${SOURCE_PATH}/src/c4/ext/fast_float")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/c4core)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c4core)
endif()

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/c4core/c4coreConfig.cmake" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
