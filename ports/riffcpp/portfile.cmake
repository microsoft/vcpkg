vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdmusic/riffcpp
    REF  v2.2.4
    SHA512 abceba02441305267c444ed724ca769fa08369302eb74b7729b700883b9354f3db95d8c68ee15f25844a75f1609edd2bcf7482fc639b9e2d3ee3b8caf5e9585f
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DRIFFCPP_INSTALL_EXAMPLE=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/riffcpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/riffcpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/riffcpp/copyright)
