vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sainteos/tmxparser
    REF v2.1.0
    HEAD_REF master
    SHA512 011cce3bb98057f8e2a0a82863fedb7c4b9e41324d5cfa6daade4d000c3f6c8c157da7b153f7f2564ecdefe8019fc8446c9b1b8a675be04329b04a0891ee1c27
    PATCHES
        fix_include_paths.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB LIBS ${CURRENT_PACKAGES_DIR}/lib/*.so* ${CURRENT_PACKAGES_DIR}/debug/lib/*.so*)
    if(LIBS)
        file(REMOVE ${LIBS})
    endif()
else()
    file(GLOB LIBS ${CURRENT_PACKAGES_DIR}/lib/*.a ${CURRENT_PACKAGES_DIR}/debug/lib/*.a)
    if(LIBS)
        file(REMOVE ${LIBS})
    endif()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
