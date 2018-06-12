include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.1
        SHA512 16921b997071e5717b9207e2fe6e4595759fd8bf872ac1f37c57b01b59e9dbe8f4f16140556ea4ee69966458360d01635caef70fb864f0ec1d43f7b63e009952
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