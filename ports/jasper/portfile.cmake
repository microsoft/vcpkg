include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mdadams/jasper
    REF version-2.0.14
    SHA512 6b270cb1eb55f777f30016f3258e5e2297627e7d086334814c308464f5a4552c23241b0fdbc81ea715a6f4746294657f96c1cb6ceb320629ce57db7e81d84940
    HEAD_REF master)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/jasper-fix-uwp.patch
        ${CMAKE_CURRENT_LIST_DIR}/opengl-not-required.patch
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
        -DJAS_ENABLE_OPENGL=OFF # not needed for the library
        -DJAS_ENABLE_DOC=OFF
        -DJAS_ENABLE_PROGRAMS=OFF
        -DJAS_ENABLE_SHARED=${JAS_ENABLE_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jasper)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jasper/LICENSE ${CURRENT_PACKAGES_DIR}/share/jasper/copyright)
