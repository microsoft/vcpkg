vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF f2c98ccc7173afcc8101d188c24b4ac6ea87e125
    SHA512 65648923e038c521774e1a1bd42b119262bfeff022d780ebacd3ba6be7c30f1ad322f82683733a8c280bc7c5eec49b0adf95a3864f8c5a84e3741a9bb4220cd9
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_FSWATCH=OFF"
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
