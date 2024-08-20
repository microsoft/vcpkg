vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF a19d7db16232b160901cc65b8398ece2526b5e41 #v1.1.2
    SHA512 867f3c07073a9c9ce60d95d8c6eff37e49bd10d45fd93891cbdd7b6e77e5302048b7b054b597d382f1f581636a8b3042291d87a9eadd7f2b33c4c532dc23ae5d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DCTL_CACHE_LINE_SIZE=0"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
