vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/nsync
    REF 1.22.0
    SHA512 e62e3f1ee736da871c7d6bd579ed1e22c5be23045372eec11e9d48f09e2b6822e026d846d864a94b4b0112c67643afab2e9ac04cee26138677eddc31d7d48c23
    HEAD_REF master
    PATCHES
        001-add-install-dependency.patch # Do not allow 'install' target to be built before 'all' target is built
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    -DNSYNC_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)