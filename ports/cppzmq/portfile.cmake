include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/cppzmq
    REF 8d5c9a88988dcbebb72939ca0939d432230ffde1 # v4.6.0
    SHA512 45f94a8473cafa6a764a7b4d037284ce2fabbc542a763865f7af6885ebe44498f06215092e4bf4f5d7d26b2fb5585316ed022e300e9c2a8b9647284a444345b2
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
