include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.7
        SHA512 2f2717d860ad55ca97f2a6e9ee50a82f88def78585feafb2fb961fd16a3d239607807a1352f1988f081c6375670bcbe409e27b9786547b83762702dbdfbbfe82
        HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSHIVA_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shiva)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shiva)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shiva/LICENSE ${CURRENT_PACKAGES_DIR}/share/shiva/copyright)
