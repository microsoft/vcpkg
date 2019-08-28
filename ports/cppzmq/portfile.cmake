include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/cppzmq
    REF v4.4.1
    SHA512 5178a24413e44a6d99e57db7c9859c72279304272baa0e1fb810174cdf592cb567cab98428ef3ab611042bdf4bc506867421662409d1f0d82c233cb83ebdb801
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCPPZMQ_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/cppzmq)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/cppzmq/libzmq-pkg-config)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppzmq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppzmq/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppzmq/copyright)
