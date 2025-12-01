vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Get c4core src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/c4core
    REF "v${VERSION}"
    SHA512 c9264bc404a60c9eb926f53998bdf87338792a1c5c687cee9034620965abbe383ac413cfc9dc57bc571596d60c46df99df292229a26dbee232fb43fe40750092
    HEAD_REF master
    PATCHES
        disable-cpack.patch
)

set(CM_COMMIT_HASH 469017f6ddab72e860aa80221736c00d3dae0587)

# Get cmake scripts for c4core
vcpkg_download_distfile(
    CMAKE_ARCHIVE
    URLS "https://github.com/biojppm/cmake/archive/${CM_COMMIT_HASH}.zip"
    FILENAME "cmake-${CM_COMMIT_HASH}.zip"
    SHA512 858200265b335297fefacf23780d2db596f09fe71dd04088ec34fa29d6d962dc04ece3429108ad3332289cbf41da2cae6991ac6211ff12f6c796ca4e25b7ceef
)

vcpkg_extract_source_archive(
    SOURCE_PATH_CMAKE
    ARCHIVE ${CMAKE_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${SOURCE_PATH_CMAKE}" "${SOURCE_PATH}/cmake")

set(DB_COMMIT_HASH 328e4abca3384cbd0a69e70f263cc7b2794bff09)

vcpkg_download_distfile(
    DEBUGBREAK_ARCHIVE
    URLS "https://github.com/biojppm/debugbreak/archive/${DB_COMMIT_HASH}.zip"
    FILENAME "debugbreak-${DB_COMMIT_HASH}.zip"
    SHA512 47208fd7578d7fa0ff2d9170955b073cd761b271bc512072eab3bfd8e7f06d4bd5503837957acd388cbb95fde7f67b4c024f8809a1214417400f3bed4dab3ece
)

vcpkg_extract_source_archive(
    SOURCE_PATH_DEBUGBREAK  
    ARCHIVE ${DEBUGBREAK_ARCHIVE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src/deps"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/c4/ext/debugbreak")
file(RENAME "${SOURCE_PATH_DEBUGBREAK}" "${SOURCE_PATH}/src/c4/ext/debugbreak")

set(FF_COMMIT_HASH d28a3320c2de0963b6e469b8ca3bbc36496de684)

vcpkg_download_distfile(
    FAST_FLOAT_ARCHIVE
    URLS "https://github.com/biojppm/fast_float/archive/${FF_COMMIT_HASH}.zip"
    FILENAME "fast_float-${FF_COMMIT_HASH}.zip"
    SHA512 7642badc0af2e57303667de4fe6dbd61b633d82e9a42571f241a2e4ae8e385529096b4dcf22e7beb6998bf36f28eec10f7af396032db41f6a59ab6a8bffaf34a
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
