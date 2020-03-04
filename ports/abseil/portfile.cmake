vcpkg_fail_port_install(ON_ARCH "arm" "arm64")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 06f0e767d13d4d68071c4fc51e25724e0fc8bc74 #commit 2020-03-03
    SHA512 f6e2302676ddae39d84d8ec92dbd13520ae214013b43455f14ced3ae6938b94cedb06cfc40eb1781dac48f02cd35ed80673ed2d871541ef4438c282a9a4133b9
    HEAD_REF master
    PATCHES 
        fix-lnk2019-error.patch
        fix-uwp-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/absl TARGET_PATH share/absl)

vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/include/absl/copts
                    ${CURRENT_PACKAGES_DIR}/include/absl/strings/testdata
                    ${CURRENT_PACKAGES_DIR}/include/absl/time/internal/cctz/testdata)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)