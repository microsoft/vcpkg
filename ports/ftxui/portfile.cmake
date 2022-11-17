vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArthurSonzogni/FTXUI
    REF c033ca61ae8fb264542d0326d1309e0a3bde945a # 3.0.0
    SHA512 ca1468f30f90c3a886fbb6dea113699623d601da10b39a6a33d89780cd825bec8deb431872a2515fce05c7a5d581d4b56860b19654df8cf90e389dfa964f013c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFTXUI_BUILD_EXAMPLES=OFF
        -DFTXUI_ENABLE_INSTALL=ON
        -DFTXUI_BUILD_TESTS=OFF
        -DFTXUI_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
