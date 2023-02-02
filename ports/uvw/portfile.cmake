#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF 3db9e8f75a4351325e1ea00e17586af2b00cf1ea # v2.12.1_libuv_v1.44
    SHA512 35e799fe877abc26ae44d20c9b5b292497d1468d9f89c0fc19b96a0b0712e35084480100e2fe7324353e2c3805c2f018e89192357d974bfd009af9b58bfcb7ec
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/uvw-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/uvw/")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright/readme/package files
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
