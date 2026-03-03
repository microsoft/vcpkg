vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 d514039c3879c1b5445a236fdedae427b44cedcdee7646fc3533b909b2716169742f1117281a8de370ba9a27c81bd09d713c7da22cad2290851f81915887698f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DITCH_BUILD_TESTS=OFF
        -DITCH_BUILD_BENCHMARKS=OFF
        -DITCH_BUILD_EXAMPLES=OFF
        -DITCH_PROJECT_ENV=PROD
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "itch"
    CONFIG_PATH "lib/cmake/itch"
   
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
