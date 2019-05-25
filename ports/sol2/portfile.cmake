include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 4f66c304df070c31776093625696aca2863c288d
    SHA512 2115715d3b37c516577f1c0449c91c13402e9babeeb2b02542ec989b9e9e995393d07efd224f804c31283fc94dde703dcee9789f1ba38f2c7c215193a7cd8922
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sol2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sol2 RENAME copyright)
