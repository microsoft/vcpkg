vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mdadams/jasper
    REF version-2.0.16
    SHA512 b3bca227f833567c9061c4a29c0599784ed6a131b5cceddfd1696542d19add821eda445ce6d83782b454b266723b24d0f028cbc644a25c0e3a75304e615b34ee
    HEAD_REF master
    PATCHES fix-find-freeglut.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(JAS_ENABLE_SHARED ON)
else()
    set(JAS_ENABLE_SHARED OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=OFF
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_DOC=OFF
        -DJAS_ENABLE_PROGRAMS=OFF
        -DJAS_ENABLE_SHARED=${JAS_ENABLE_SHARED}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d # Due to CMakes FindJasper
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
                    ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
                    ${CURRENT_PACKAGES_DIR}/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
