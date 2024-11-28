vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF "v${VERSION}"
    SHA512 5281557d05faa95f25a509a03d331ecf60b881cfbe0d80f560a9a1be1957d5b3b7a9afa99e1ffb35175f30b357fea3103058665f56bcecea55df9efa23179619
    HEAD_REF master
)

# head only library
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCAW_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
