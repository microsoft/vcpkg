vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF "v${VERSION}"
    SHA512 e517b050a7a56b57ea2035322736dd20fa704e0a642d3c3e577caa771ddd126661981c6e15ae66ecaea97367f9e86748d6d26ff02579ab3ec6e48db25a2056e1
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENTT_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/EnTT/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install natvis files
file(INSTALL "${SOURCE_PATH}/natvis/entt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/natvis")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
