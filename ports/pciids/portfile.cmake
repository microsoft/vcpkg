# This package doesn't "install" the pciids data file but
# provides a maintainer function which does the download.

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

include("${CMAKE_CURRENT_LIST_DIR}/acquire_pciids.cmake")
acquire_pciids(pciids_path)
cmake_path(GET pciids_path PARENT_PATH pciids_dir)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/acquire_pciids.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${pciids_dir}/README")
