include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF fed8594a0144fb953ab04fd6040398f4e0e8bc97
    SHA512 efec76d7ffa610407a71f666667e94444d8dc843ebe4387b3166cb290d55367cfcda6f97ff585208a20d73d6f1d41d31778707fa18a43b2e263bf0b43301747f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncons)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncons/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncons/copyright)
