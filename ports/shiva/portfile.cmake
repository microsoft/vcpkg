include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 1.0
        SHA512 d1ce33e89b17fa8f82e21b51dfa1308e38c617fea52c34a20b7b6c8643318280df24c043238ddd73ba2dbc139c5b5de1c2cb3add1f5629a54694c78b415d73d1
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
