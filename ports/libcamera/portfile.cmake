vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.libcamera.org/libcamera/libcamera.git
    REF 058f589ae36170935e537910f2c303b1c3ea03b3
    FETCH_REF "v${VERSION}"
    HEAD_REF master
    PATCHES
        fix-absolute-paths.patch
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(
    PYTHON_VERSION 3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES "jinja2" "PyYaml" "ply"
)

# Scripts are invoking 'openssl' by name
vcpkg_host_path_list(APPEND ENV{PATH} "${CURRENT_HOST_INSTALLED_DIR}/tools/openssl")

vcpkg_list(SET options)
if("tracing" IN_LIST FEATURES)
    list(APPEND options "-Dtracing=enabled")
else()
    list(APPEND options "-Dtracing=disabled")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -Dcam=disabled # This is a test application
        -Ddocumentation=disabled
        -Dgstreamer=enabled
        -Dlc-compliance=disabled # Test appplication
        -Dpycamera=disabled # experimental feature, going to leave for later
        -Dqcam=disabled # Test application
        -Dtest=false # Unit tests
        -Dv4l2=enabled
        -Dudev=enabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.rst")

