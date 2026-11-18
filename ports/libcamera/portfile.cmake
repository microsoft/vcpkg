vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO camera/libcamera
    REF "v${VERSION}"
    SHA512 21ada092a1944c3476e0a254fe82d2775d2eb833d931dd051bd551a9f12ae596b3cd57f3792335d4ad86479e2247d23056d30e2631aa620897d067002c88e060
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
        -Dpipelines=simple,uvcvideo
        -Dpycamera=disabled # experimental feature, going to leave for later
        -Dqcam=disabled # Test application
        -Drpi-awb-nn=disabled
        -Dsoftisp-gpu=disabled
        -Dtest=false # Unit tests
        -Dv4l2=enabled
        -Dudev=enabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.rst")
