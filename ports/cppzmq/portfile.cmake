vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/cppzmq
    REF 76bf169fd67b8e99c1b0e6490029d9cd5ef97666 # v4.7.1
    SHA512 03d7444b36937521e2826c7dd2f6cf55d820d0e4d66c30e3947527e13ba2d7cd68f426b5bfedb5a0d0deb4245893a872d5132b68ef966063d72fcd95e42e3eed
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        draft ENABLE_DRAFTS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DCPPZMQ_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/cppzmq)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/${PORT}/libzmq-pkg-config)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
