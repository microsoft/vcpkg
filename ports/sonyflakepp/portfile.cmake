vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Shadowrom2020/sonyflakepp
    REF 1.0.1
    SHA512 efa07aa17109bf97cc3fcb93f40c840a0ecd29754699c5739c9cbe805d6b0d3aef93ab885bd45f1d0278a9b3ef42ce163dc0751084df33375d39fdeb4ef0c5cf
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/sonyflakepp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
