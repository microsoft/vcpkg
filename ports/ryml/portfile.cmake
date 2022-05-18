vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Get rapidyaml src
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biojppm/rapidyaml
    REF affafd5db67208eb85413327595507314c068525
    SHA512 31d827ead680828b3c0ad879290b17d4729d412e30a20459aea4b92a8f4f3b8397f82b09c27d918ab4b955289560b17697d5f15eaa4d24661ff46f5dbbc50fa8
    HEAD_REF master
    PATCHES cmake-fix.patch
)

set(CM_COMMIT_HASH fe41e86552046c3df9ba73a40bf3d755df028c1e)

# Get cmake scripts for rapidyaml
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

file(REMOVE_RECURSE "${SOURCE_PATH}/ext/c4core/cmake")
file(RENAME ${SOURCE_PATH_CMAKE} "${SOURCE_PATH}/ext/c4core/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        def-callbacks RYML_DEFAULT_CALLBACKS
        dbg           RYML_DBG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/ryml")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ryml)
endif()

# Move headers and natvis to own dir
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/ryml")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml.hpp" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml.hpp")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml_std.hpp" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml_std.hpp")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/ryml.natvis" "${CURRENT_PACKAGES_DIR}/include/ryml/ryml.natvis")

# Fix paths in headers file
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml.hpp" "./c4" "../c4")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ryml/ryml_std.hpp" "./c4" "../c4")

# Fix paths in config file
file(READ "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" _contents)
string(REGEX REPLACE [[[ \t\r\n]*"\${PACKAGE_PREFIX_DIR}[\./\\]*"]] [["${PACKAGE_PREFIX_DIR}/../.."]] _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ryml/rymlConfig.cmake" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)