include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/ring-span-lite
    REF v0.3.0
    SHA512 5ecbfc63b4a09cc382edc2acae41a45946c9c6a18aa48e855201366b7696df7cbf46c2de1b5aa5296ae2dde4360d5abd8efdc3e3a1c3d427fbbddadab7dcfe79
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRING_SPAN_LITE_OPT_BUILD_TESTS=OFF
        -DRING_SPAN_LITE_OPT_BUILD_EXAMPLES=OFF
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
