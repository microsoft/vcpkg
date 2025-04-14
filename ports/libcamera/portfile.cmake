vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.libcamera.org/libcamera/libcamera.git
    REF 058f589ae36170935e537910f2c303b1c3ea03b3
    HEAD_REF master
    PATCHES
        fix-absolute-paths.patch
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(MESON)

x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES "jinja2" "PyYaml" "ply"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.rst")