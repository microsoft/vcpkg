include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwzx/nngpp
    REF nng-v1.2.4
    SHA512 6f30bacbf46c00c606099407e4d92d607c6010e8460b7abe25855befad1ecc67900bddcdb9aef86d7233dabb1feb8f94946618fc66cc37d2a7f982f470713f5a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNNGPP_BUILD_DEMOS=OFF
        -DNNGPP_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/license.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

