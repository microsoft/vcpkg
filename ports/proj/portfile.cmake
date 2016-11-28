include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/proj-4.9.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/proj/proj-4.9.3.zip"
    FILENAME "proj-4.9.3.zip"
    SHA512 c9703008cd1f75fe1239b180158e560b9b88ae2ffd900b72923c716908eb86d1abbc4230647af5e3131f8c34481bdc66b03826d669620161ffcfbe67801cb631
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/0001-CMake-add-detection-of-recent-visual-studio-versions.patch
    ${CMAKE_CURRENT_LIST_DIR}/0002-CMake-fix-error-by-only-setting-properties-for-targe.patch
    ${CMAKE_CURRENT_LIST_DIR}/0003-CMake-configurable-cmake-config-install-location.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND CMAKE_OPTIONS "-DBUILD_LIBPROJ_SHARED=YES")
else()
    list(APPEND CMAKE_OPTIONS "-DBUILD_LIBPROJ_SHARED=NO")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${CMAKE_OPTIONS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/proj
    -DPROJ_CMAKE_CONFIG_SUBDIR=share/proj
    -DBUILD_CS2CS=NO
    -DBUILD_PROJ=NO
    -DBUILD_GEOD=NO
    -DBUILD_NAD2BIN=NO
    -DPROJ4_TESTS=NO
)

vcpkg_install_cmake(
    -DBUILD_CS2CS=NO
    -DBUILD_PROJ=NO
    -DBUILD_GEOD=NO
    -DBUILD_NAD2BIN=NO
    -DPROJ4_TESTS=NO
)

# Rename library and adapt cmake configuration 
# N.B. debug cmake export is not copied, as it's not relocatable
file(READ ${CURRENT_PACKAGES_DIR}/share/proj/proj4-targets-release.cmake PROJ4_TARGETS_RELEASE)
string(REPLACE "proj_4_9.lib" "proj.lib" PROJ4_TARGETS_RELEASE ${PROJ4_TARGETS_RELEASE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/proj/proj4-targets-release.cmake ${PROJ4_TARGETS_RELEASE})

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/proj_4_9.lib  ${CURRENT_PACKAGES_DIR}/lib/proj.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/proj_4_9_d.lib  ${CURRENT_PACKAGES_DIR}/debug/lib/projd.lib)

# Remove duplicate headers installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove data installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
 
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/proj)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/proj/COPYING ${CURRENT_PACKAGES_DIR}/share/proj/copyright)
