vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ll-tg/ll-cpp
    REF v0.1.1
    SHA512 837bedd10f4ab7f0e3123672a1a77046bf73042ef207cfbe75476cb9c60d248115cbbed5e4f64f2aa1cbe22fe3bfecc9fb22b21ed17d0ed6d56a85eaa7cf6f48
    PATCHES fix-msvc-warning-flags.patch
           fix-windows-sockets.patch
)

file(READ "${SOURCE_PATH}/cmake/llcppConfig.cmake.in" LLCPP_CONFIG)
string(REPLACE
    "@PACKAGE_INIT@\n"
    "@PACKAGE_INIT@\ninclude(CMakeFindDependencyMacro)\nfind_dependency(Threads)\n"
    LLCPP_CONFIG
    "${LLCPP_CONFIG}"
)
file(WRITE "${SOURCE_PATH}/cmake/llcppConfig.cmake.in" "${LLCPP_CONFIG}")

file(READ "${SOURCE_PATH}/CMakeLists.txt" LLCPP_CMAKE)
string(REPLACE
    "target_link_libraries(llcpp PUBLIC Threads::Threads)"
    "target_link_libraries(llcpp PUBLIC Threads::Threads)\nif(WIN32)\n  target_link_libraries(llcpp PUBLIC ws2_32)\nendif()"
    LLCPP_CMAKE
    "${LLCPP_CMAKE}"
)
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${LLCPP_CMAKE}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLLCPP_BUILD_RUNTIME=OFF
        -DLLCPP_BUILD_EXAMPLES=OFF
        -DLLCPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME llcpp CONFIG_PATH lib/cmake/ll-cpp)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
