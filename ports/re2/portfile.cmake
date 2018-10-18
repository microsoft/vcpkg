include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 4c916c947ab7f2ba2d280bb8c87540c365d30695
    SHA512 7f34073415b2afd36469a0ffedb5d6d38b0230a82d633f2b45538e66d00ff0e411ffff1e34f74747c68518b1fdf07f7a601c23d39b001a75bcf9dadfc1350f04
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
