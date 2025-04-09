vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ETLCPP/etl
    REF "${VERSION}"
    SHA512 a4b0321711a8f32a934b05935bad3942c10660b7a85f00080194e5122129319215a8441011cd515c98f946d25161ecb2b12a084a72120f90722566a744d08c24
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/etl/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/etl/.vscode")
# remove templates used for generating headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/etl/generators")
file(GLOB_RECURSE PNG_FILES "${CURRENT_PACKAGES_DIR}/include/etl/*.png")
file(REMOVE ${PNG_FILES})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
