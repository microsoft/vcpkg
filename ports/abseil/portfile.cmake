vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 29235139149790f5afc430c11cec8f1eb1677607 #commit 2019-12-19
    SHA512 be34c782eb6cdb3355ab56f1592e692435a63bf19a0364980d498c75db267e986e60a3e425bd3b9c57b7f8afdb7c642eb68386165ec147a6d5b448570bbe756a
    HEAD_REF master
    PATCHES 
        fix-usage-lnk-error.patch
        fix-lnk2019-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/absl TARGET_PATH share/absl)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/include/absl/copts
                    ${CURRENT_PACKAGES_DIR}/include/absl/strings/testdata
                    ${CURRENT_PACKAGES_DIR}/include/absl/time/internal/cctz/testdata)