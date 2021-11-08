vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF af6b7652117fbdb12c9f330570e8463e00058870 # 1.7.1
    SHA512 5e8a80de17f0c0e7fe6273d180d8736c08332e4a63a474cb052eb7eee3481c046bd587a13c4763dddb0f57e71a9eb673d3e68ce0d9107dd65c2050d6436bf6b0
    HEAD_REF master
    PATCHES
        0001-win32_compiler_options.cmake.patch
        0002-no-source-dir-writes.patch
        0003-fix-copy-vendor.patch
        fix-dependency.patch
        libpq.patch
        fix-CPL_DLL.patch
        0004-fix-const-overloaded.patch
)

file(REMOVE "${SOURCE_PATH}/pdal/gitsha.cpp")

# Deploy custom CMake modules to enforce expected dependencies look-up
foreach(_module IN ITEMS FindGDAL FindGEOS FindGeoTIFF FindCurl)  # Outdated; Supplied by CMake
    file(REMOVE "${SOURCE_PATH}/cmake/modules/${_module}.cmake")
endforeach()
foreach(_module IN ITEMS FindGEOS)  # Overwritten Modules.
    file(REMOVE "${SOURCE_PATH}/cmake/modules/${_module}.cmake")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/${_module}.cmake"
        DESTINATION "${SOURCE_PATH}/cmake/modules/"
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" VCPKG_BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPDAL_BUILD_STATIC:BOOL=${VCPKG_BUILD_STATIC_LIBS}
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/pdal/cmake)
vcpkg_copy_pdbs()

# Install PDAL executable
file(GLOB _pdal_apps "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${_pdal_apps} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/pdal")
file(REMOVE ${_pdal_apps})
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# Post-install clean-up
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib/pdal"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pdal"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
else()
    file(GLOB _pdal_bats "${CURRENT_PACKAGES_DIR}/bin/*.bat")
    file(REMOVE ${_pdal_bats})
    file(GLOB _pdal_bats "${CURRENT_PACKAGES_DIR}/debug/bin/*.bat")
    file(REMOVE ${_pdal_bats})
    file(GLOB _pdal_apps "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(REMOVE ${_pdal_apps})
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
