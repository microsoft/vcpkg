vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/span-lite
    REF v0.9.0
    SHA512 e7d8a5f2e85b4aa7dc148c5a17898729bafa6124affacf66280eaa74c6aad5a4c9a9231e664f95392aa4edb784eaf3e2e3e03d34914c90565b9026744d7f7276
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPAN_LITE_OPT_BUILD_TESTS=OFF
        -DSPAN_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
