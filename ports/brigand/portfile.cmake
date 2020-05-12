include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edouarda/brigand
    REF 1.3.0
    SHA512 538d288d84265cc9a4563f1e84d55a174db461ffd1e4f510bfdaef04af9fbf8e7ca79817f9118378bf7d58d578699aae3072bbffa3fd727b2d93ee783337aea6
    HEAD_REF master
    PATCHES fix-install-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA   
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

