include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.7.2
        SHA512 0bd1543ba6067d303640820a17a24ec02c6ab8333f86bd3431c09f5a2ea4ca47379ec06a90e3a0658dba967504cb8a63f85c2f0cbfb51a7c59130b235948d600
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
