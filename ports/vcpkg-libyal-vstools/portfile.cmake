file(INSTALL
    "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake"
    "${CURRENT_PORT_DIR}/vcpkg_libyal_msvscpp_convert.cmake"
    "${CURRENT_PORT_DIR}/z_vcpkg_libyal_vstools_download.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")
set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

# Fill asset cache when run with --only-downloads
include("${CURRENT_PORT_DIR}/vcpkg-port-config.cmake")
z_vcpkg_libyal_vstools_download(unused)
vcpkg_find_acquire_program(PYTHON3)
