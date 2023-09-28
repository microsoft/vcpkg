vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVlabs/cub
    REF ed040d585c3237d706973d7ad290bfee40958270 #v1.16.0
    SHA512 81e0bacb0aa4ee7a1c86f3c12e3135a133579678d3530e0e0b8310f716d0355e5096925ac6de5865140a7aac08d974ea5169d47e34951b932a23965f74fe4ee6
    HEAD_REF master
    PATCHES fix-usage.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCUB_ENABLE_INSTALL_RULES=ON
        -DCUB_ENABLE_HEADER_TESTING=OFF
        -DCUB_ENABLE_TESTING=OFF
        -DCUB_ENABLE_EXAMPLES=OFF
        -DCUB_ENABLE_CPP_DIALECT_IN_NAMES=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cub)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/cub/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
