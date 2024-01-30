vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.2.4
    SHA512 abceba02441305267c444ed724ca769fa08369302eb74b7729b700883b9354f3db95d8c68ee15f25844a75f1609edd2bcf7482fc639b9e2d3ee3b8caf5e9585f
    HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DRIFFCPP_INSTALL_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
