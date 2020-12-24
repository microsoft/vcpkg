set(OATPP_VERSION "1.2.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-websocket
    REF 1ac81a1ae2588e9b21e4b9ecb93f7f30739fdcfe # 1.2.0
    SHA512 db70052f4399300e2fd75f6dc7fb85b3084cc7ad4fba09340707c8465cfa3ea7f63f629581722912009d450d7951c0e0b04ffec9c24fa4dcdf0aaf429cff5593
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"     
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-websocket-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
