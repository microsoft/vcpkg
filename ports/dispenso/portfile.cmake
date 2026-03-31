vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/dispenso
    REF "v${VERSION}"
    SHA512 e2a93a4780d214447151d43f3b1758229c5a4835ab4339f30f0d6e4068d8c833519891de64d13993131f3b535ae08ccd7ceca0b2b2399ef054bb523cd9b8c772
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISPENSO_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISPENSO_BUILD_TESTS=OFF
        -DDISPENSO_BUILD_BENCHMARKS=OFF
        -DDISPENSO_SHARED_LIB=${DISPENSO_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Dispenso-${VERSION}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
