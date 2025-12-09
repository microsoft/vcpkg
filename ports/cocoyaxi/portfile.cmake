vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/coost
    REF 0e89c366f707ff4ca4738f879fd5e6934bc57cc4
    SHA512 712b04cac80f230cb40497ab43a95ca8fcd922f5a8edd93f00be50d46a148b579f7f3e66985bf92ff6d0258e58fa138944c8b6c08384186e929406743b2a8872
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libcurl WITH_LIBCURL
        openssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTATIC_VS_CRT=${STATIC_CRT}
    MAYBE_UNUSED_VARIABLES
        STATIC_VS_CRT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/coost)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
