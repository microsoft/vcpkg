vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yoctopuce/yoctolib_cpp
    REF "v${VERSION}"
    SHA512 89cf1390610913a9114b0a0edd219d6c353cbec4b76c3655efe44bab0989b4ee3371cc4b671fd78068bf3d6a67d4cc52b35d9bbb9eb2df50628a4b10255b6fe1
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
