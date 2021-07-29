vcpkg_buildpath_length_warning(37)

set(OMPL_VERSION 1.5.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ompl/ompl/archive/1.5.1.tar.gz"
    FILENAME "ompl-${OMPL_VERSION}.tar.gz"
    SHA512 2f28d29f32f3bb03e67b29ce251e4786364847a25e3c4cf66d7663ed38dca4da71d4e03cf9ce647710d9524a3907c76c09795e77f041cb8822f695d28f5ca570
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${OMPL_VERSION}
    PATCHES
        0001_Export_targets.patch
        0002_Fix_config.patch
)

# Based on selected features different files get downloaded, so use the following command instead of patch.
file(READ ${SOURCE_PATH}/CMakeLists.txt _contents)
string(REPLACE "find_package(Eigen3 REQUIRED)" "find_package(Eigen3 REQUIRED CONFIG)" _contents "${_contents}")
string(REPLACE "find_package(ccd REQUIRED)" "find_package(ccd REQUIRED CONFIG)" _contents "${_contents}")
file(WRITE ${SOURCE_PATH}/CMakeLists.txt "${_contents}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_REGISTRATION=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DOMPL_BUILD_PYTESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ompl/cmake)

# Remove debug distribution and other, move ompl_benchmark to tools/ dir
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/share/ompl/demos
    ${CURRENT_PACKAGES_DIR}/share/ompl/ompl.conf
    ${CURRENT_PACKAGES_DIR}/share/ompl/plannerarena
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
