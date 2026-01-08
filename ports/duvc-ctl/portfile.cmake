vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO allanhanan/duvc-ctl
    REF "v${VERSION}"
    SHA512 5cc63ef7c3a46fb351015ae2b1b96837ea46dbb7656ab1cf633af6027d32ae447dfc60a8757677eae07dabfb3ec1aca90f7019a6d7b5344c66324d39e9f0c464
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDUVC_BUILD_SHARED=ON
        -DDUVC_BUILD_STATIC=ON
        -DDUVC_BUILD_C_API=OFF
        -DDUVC_BUILD_CLI=OFF
        -DDUVC_BUILD_TESTS=OFF
        -DDUVC_BUILD_EXAMPLES=OFF
        -DDUVC_BUILD_PYTHON=OFF
        -DDUVC_BUILD_DOCS=OFF
        -DDUVC_INSTALL=ON
        -DDUVC_INSTALL_CMAKE_CONFIG=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/duvc-ctl)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
