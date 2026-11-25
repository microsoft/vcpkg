vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO calvinhxx/Fluent-Qt
    REF "v${VERSION}"
    SHA512 c46a0ffe16ca9eeeb78dfe3d2a47409399b66d684d7605b6bf510ad316bb3ab869856b0c114dc430309fbb84f4235a65eac23ba1903caac11270bb8c5c749530
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUENT_QT_BUILD_EXAMPLES=OFF
        -DFLUENT_QT_DEBUG_RELEASE_RUNTIME=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME FluentQt CONFIG_PATH lib/cmake/FluentQt)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/share/licenses"
)
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
    "${SOURCE_PATH}/TRADEMARKS.md"
    "${SOURCE_PATH}/third_party/fonts/inter/LICENSE.txt"
    "${SOURCE_PATH}/third_party/icons/fluentui-system-icons/LICENSE.txt"
    "${SOURCE_PATH}/third_party/icons/fluentui-system-icons/NOTICE.txt"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
