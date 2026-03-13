vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yoctopuce/yoctolib_cpp
    REF "v${VERSION}"
    SHA512 3bca6331fb19b36b1a3638c8139e368125e190563acb92f6f2106a0094da2d0508456d706c9ee3ee67741bf14f02cfa734c8499becc4491b208d541b26b4d63c
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Sources"
    OPTIONS
        -DVERSION=${VERSION}
        -DCMAKE_INSTALL_INCLUDEDIR=include/yoctolib
        -DUSE_YSSL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME yoctolib)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
