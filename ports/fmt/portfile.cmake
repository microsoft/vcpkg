vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF "${VERSION}"
    SHA512 6188508d74ca1ed75bf6441b152c07ca83971d3104b37f33784a7b55dfcc614d6243e77e0a14220018586fdb86207cc033eece834e7acd5e0907ed4c97403f3b
    HEAD_REF master
    PATCHES
        fix-write-batch.patch
        fix-format-conflict.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/fmt/core.h
        "defined(FMT_SHARED)"
        "1"
    )
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst")
