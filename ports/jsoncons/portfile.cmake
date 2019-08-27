include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF v0.132.1
    SHA512 74bfe6fe18e90f4230b9d811a01f263e4597f6363f4df0cb29a89148bbc040ab578a1eb77d3cb87ce0d8e9d304b9716dd245f4dc5603c7d445cd0acdfb62905d
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
