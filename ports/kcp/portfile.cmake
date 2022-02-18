vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skywind3000/kcp
    REF 38e0c9366e4a72c749ff0bcdf911d1fe9bdfe9f5
    SHA512 1a05a692719f7f7bfa2e20df81c68af991bd01fe7236ab637a10644abfed425b9f46fd9ad399b8edca152d7bb617c37533b183bda2cf4a0cc1c3ce47031ba37f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
