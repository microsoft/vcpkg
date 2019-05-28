include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/observer-ptr-lite
    REF v0.3.0
    SHA512 929a08946f3fe13de0456c241900d9924762bc4b963daf7f677dcc7ab2d860f5276742230079b99bd59cc320ff91f2e2eedbd56dfaa20ec35483bd56f2fc104c
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNSOP_OPT_BUILD_TESTS=OFF
        -DNSOP_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(
#    CONFIG_PATH lib/cmake/${PORT}
#)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
