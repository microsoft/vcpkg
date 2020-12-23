vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 38fe6b0fe8a624bed5c6d0c9a600d0abb2db62a3 # v.0.6.12
    SHA512 34e0eed7560a05725158cf47ca77e69746c6134f6e1579de30b7130d0010a92dea429755021ef52745d14a0358b12b205ddaec698c0b8e1a75b853d6a303537b
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
