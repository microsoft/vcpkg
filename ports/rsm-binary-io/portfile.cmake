vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/binary_io
    REF 2.0.5
    SHA512 787833487b9e2b64aeb73842024a52a6ad646d2609342983ebf1539878b96565bf329c8b05afca0fb35a1e40a91174131ad7a0bdc79b168a12bf02f3d6e0cd6d
    HEAD_REF main
)

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "Build ${PORT} requires at least gcc 10.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME binary_io
    CONFIG_PATH "lib/cmake/binary_io"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
