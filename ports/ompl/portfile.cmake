vcpkg_buildpath_length_warning(37)

set(OMPL_VERSION 1.5.0)

set(FEATURE_PATCHES)

if("app" IN_LIST FEATURES)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ompl/omplapp/releases/download/1.5.0/omplapp-1.5.0-Source.tar.gz"
        FILENAME "omplapp-${OMPL_VERSION}.tar.gz"
        SHA512 ad221b67146915cb63be6731ca2fa7d827d85b7fd175d87ee64c799311dfe4878935881b1ae6447357fdd178f70c9aa01b178e857261a8d8769affa1e58ed72b
    )
    list(APPEND FEATURE_PATCHES fix_dependency.patch)
else()
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ompl/ompl/archive/1.5.0.tar.gz"
        FILENAME "ompl-${OMPL_VERSION}.tar.gz"
        SHA512 a300682fa0af40768c93e44b819c677b6121812e4f968ad89b5ae4044f3171a7febca63fa5645f2ad0f99ec3dfb3b02fe8c7443c4e389bf19a4a4bc9c7a5d013
    )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${OMPL_VERSION}
    PATCHES ${FEATURE_PATCHES}
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
if ("app" IN_LIST FEATURES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/ompl)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ompl_benchmark.exe ${CURRENT_PACKAGES_DIR}/tools/ompl/ompl_benchmark.exe)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/include/omplapp/CMakeFiles
        ${CURRENT_PACKAGES_DIR}/share/ompl/resources
        ${CURRENT_PACKAGES_DIR}/share/ompl/webapp
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
