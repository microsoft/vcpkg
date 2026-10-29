vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flintlib/flint
    REF v${VERSION}
    SHA512 f1057affd37d2460522fbd4620454616571d3a8220d53fa6ee668d8cec25f7996275ec00decaf4b4d9a799db117419192b68f4c3b720f094d12d9b4cf2aa977a
    HEAD_REF master
    PATCHES
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(PYTHON3)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        DISABLE_PARALLEL_CONFIGURE # see configure_file(${CMAKE_CURRENT_SOURCE_DIR} ...
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
