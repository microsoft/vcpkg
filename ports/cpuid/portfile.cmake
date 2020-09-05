vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm" "arm64")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF f2ab8b7ef2c286f619d96c3ce8902cb76b801bf0
    SHA512 fcd2d35994554eed80c04315f1cf3bc91f272a5051dde040fe2266d71af902b60ecfd74b6f9dc8284a22f222208c6789bfb94cc12d61de17d605265d3cd2c43d
    HEAD_REF master
    PATCHES fix-install-headers.patch
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
        -DENABLE_DOCS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cpuid)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
