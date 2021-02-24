vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jamboree/bustache
    REF abb25ca189425783c6b7ec5c17c5284dccb59faf
    SHA512 be00451f6a85edccacbdd5d8478d7af4f3162f9a9a31af876004237ca7f303c1262b2ea623e6ec595d73440dc14fcf22d185bc521fd3aca6e28ec43890d611c5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/bustache/cmake")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
