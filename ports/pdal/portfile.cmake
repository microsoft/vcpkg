set(PDAL_VERSION_STR "2.2.0")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF 2.2.0
    SHA512 26acd2197df3083e1f2de705beb9a5fede1b5a10cdf3c6c0e161c5fc64ed71c70f2f487f6a28b5198959b39885a0f691bf306cdab940de8002058a23ec16982e
    PATCHES
        reimplement-patch-172-in-220.patch
)

# Deploy custom CMake modules to enforce expected dependencies look-up
foreach(_module IN ITEMS FindGDAL FindGeoTIFF FindCurl)  # Outdated; Supplied by CMake
    file(REMOVE "${SOURCE_PATH}/cmake/modules/${_module}.cmake")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
  set(VCPKG_BUILD_STATIC_LIBS OFF)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
  set(VCPKG_BUILD_STATIC_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPDAL_BUILD_STATIC:BOOL=${VCPKG_BUILD_STATIC_LIBS}
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pdal)
vcpkg_copy_pdbs()

# Install PDAL executable
file(GLOB _pdal_apps ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(COPY ${_pdal_apps} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/pdal)
file(REMOVE ${_pdal_apps})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

# Post-install clean-up
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib/pdal
    ${CURRENT_PACKAGES_DIR}/debug/lib/pdal
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share

    # These are intentionally? empty
    ${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/csf
    ${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/miniball
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/a/dir" "${CURRENT_PACKAGES_DIR}/some/other/dir")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
else()
    file(GLOB _pdal_bats ${CURRENT_PACKAGES_DIR}/bin/*.bat)
    file(REMOVE ${_pdal_bats})
    file(GLOB _pdal_bats ${CURRENT_PACKAGES_DIR}/debug/bin/*.bat)
    file(REMOVE ${_pdal_bats})
    file(GLOB _pdal_apps ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${_pdal_apps})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
