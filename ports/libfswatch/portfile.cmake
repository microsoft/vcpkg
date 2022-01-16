vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF f78857599f7f65dff3ad3b3f1e28deaee8dab901
    SHA512 654b8200a54cc18b948df6ad2d1dd88dd4b7913e91bd156f3c9fb3e91b9ffc3805508b3c5eeba22a6085d3a81274db65dd97fb0816ddbf91a1a823a9f03a74c8
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
