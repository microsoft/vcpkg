set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg_spdx_license_file.cmake"
             "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_spdx_license_file.cmake")
vcpkg_spdx_license_file(MIT)
vcpkg_install_copyright(FILE_LIST "${MIT}")
