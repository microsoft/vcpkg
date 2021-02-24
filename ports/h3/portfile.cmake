vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO uber/h3
        REF v3.6.3
        SHA512 925438663ef9fb6541e4655dc95febe6233f078f8277937d8a9b33a76cf9b257d8c14e3ac5109460ac9188c426e6997700c4ec17926cf401577b3faf74c6c320
        HEAD_REF master
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_FILTERS=OFF
        -DBUILD_GENERATORS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
