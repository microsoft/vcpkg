vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VERSION STREQUAL "1.12.3")
    vcpkg_download_distfile(direct_include_patch
        URLS "https://github.com/calvinhxx/Fluent-Qt/commit/7c1b0c1a551be25b6b40315c8b9cdd6fef2a104b.patch?full_index=1"
        FILENAME "fluent-qt-1.12.3-direct-include.patch"
        SHA512 d3ce1cdfb67b54b8f938b03086f4204c8df824eb1c142fb5c29c151569377bf7fcd42e00b7a24cdf1378386d6e6b4290ad729578a0c5d5b411e08e52eefbdef6
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO calvinhxx/Fluent-Qt
    REF "v${VERSION}"
    SHA512 c46a0ffe16ca9eeeb78dfe3d2a47409399b66d684d7605b6bf510ad316bb3ab869856b0c114dc430309fbb84f4235a65eac23ba1903caac11270bb8c5c749530
    PATCHES ${direct_include_patch}
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
