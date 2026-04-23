vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flintlib/flint
    REF d612c084522b54d727963e9b6579788ea46c3006
    SHA512 b4dba0ff70296615e8a997d5cbbce321334dfc54f7a02888d345d3d52e67c8d0b9dcbfa4dd4d387cbd7f11ac3c62e01525b3b326d08b2c1d008510291f479185
    HEAD_REF master
    PATCHES
        fix-msvc-x86.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(PYTHON3)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "-DPython_EXECUTABLE=${PYTHON3}"
            -DVCPKG_LOCK_FIND_PACKAGE_CBLAS=OFF
            -DWITH_NTL=OFF
    )
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flint)
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            --with-ntl=no
            --with-blas=no
    )
    vcpkg_make_install()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
