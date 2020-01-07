set(PDAL_VERSION_STR "1.7.1")

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/pdal/PDAL-${PDAL_VERSION_STR}-src.tar.gz"
    FILENAME "PDAL-${PDAL_VERSION_STR}-src.tar.gz"
    SHA512 e3e63bb05930c1a28c4f46c7edfaa8e9ea20484f1888d845b660a29a76f1dd1daea3db30a98607be0c2eeb86930ec8bfd0965d5d7d84b07a4fe4cb4512da9b09
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        0001-win32_compiler_options.cmake.patch
        0002-no-source-dir-writes.patch
        0003-fix-copy-vendor.patch
        PDALConfig.patch
        fix-dependency.patch
)

file(REMOVE "${SOURCE_PATH}/pdal/gitsha.cpp")

# Deploy custom CMake modules to enforce expected dependencies look-up
foreach(_module IN ITEMS FindGDAL FindGEOS FindGeoTIFF FindCurl)  # Outdated; Supplied by CMake
    file(REMOVE "${SOURCE_PATH}/cmake/modules/${_module}.cmake")
endforeach()
foreach(_module IN ITEMS FindGEOS)  # Overwritten Modules.
    file(REMOVE "${SOURCE_PATH}/cmake/modules/${_module}.cmake")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/${_module}.cmake
        DESTINATION ${SOURCE_PATH}/cmake/modules/
    )
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/pdal/cmake)
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
)

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
