vcpkg_buildpath_length_warning(37)

set(OMPL_VERSION 1.5.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ompl/omplapp/releases/download/1.5.1/omplapp-1.5.1-Source.tar.gz"
    FILENAME "omplapp-${OMPL_VERSION}.tar.gz"
    SHA512 83b1b09d6be776f7e15a748402f0c2f072459921de61a92731daf5171bd1f91a829fbeb6e10a489b92fba0297f6272e7bb6b8f07830c387bb29ccdbc7b3731f3
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(STATIC_PATCH fix_boost_static_link.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${OMPL_VERSION}
    PATCHES
        fix_dependency.patch
        ${STATIC_PATCH}
)

# Based on selected features different files get downloaded, so use the following command instead of patch.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(Eigen3 REQUIRED)" "find_package(Eigen3 REQUIRED CONFIG)")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(ccd REQUIRED)" "find_package(ccd REQUIRED CONFIG)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_REGISTRATION=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DOMPL_BUILD_PYTESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/ompl/cmake)

# Remove debug distribution and other, move ompl_benchmark to tools/ dir
vcpkg_copy_tools(TOOL_NAMES ompl_benchmark AUTO_CLEAN)
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/ompl"
    "${CURRENT_PACKAGES_DIR}/bin"
    "${CURRENT_PACKAGES_DIR}/include/omplapp/CMakeFiles"
    "${CURRENT_PACKAGES_DIR}/lib/ompl.lib"
    "${CURRENT_PACKAGES_DIR}/share/ompl"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/ompl.lib"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/omplapp/config.h" "#define OMPLAPP_RESOURCE_DIR \"${CURRENT_PACKAGES_DIR}/share/ompl/resources\"" "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ompl.pc" "assimp::assimp" "assimp")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ompl.pc" "assimp::assimp" "assimp")
    endif()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
