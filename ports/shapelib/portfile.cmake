include(vcpkg_common_functions)

set(SHAPELIB_VERSION 1.4.1)
set(SHAPELIB_HASH e3e02dde8006773fed25d630896e79fd79d2008a029cc86b157fe0d92c143a9fab930fdb93d9700d4e1397c3b23ae4b86e91db1dbaca1c5388d4e3aea0309341)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/shapelib/shapelib-${SHAPELIB_VERSION}.zip"
    FILENAME "shapelib-${SHAPELIB_VERSION}.zip"
    SHA512 ${SHAPELIB_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        option-build-test.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TEST=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/shapelib)
    file(REMOVE ${EXES})
endif()

file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(DEBUG_EXES)
    file(REMOVE ${DEBUG_EXES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/shapelib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shapelib/COPYING ${CURRENT_PACKAGES_DIR}/share/shapelib/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/shapelib)

vcpkg_copy_pdbs()
