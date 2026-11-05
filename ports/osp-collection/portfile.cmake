vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-patterns/collection
    REF "${VERSION}"
    SHA512 140d654642f1ab29dda2786700ae8238adcf578dcba20401dae4473a4aabd75cf7a214450870d233fcb0dad0302fe397fd5bbc25129bc41cdba38b9ea58cc48a
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DCOLLECTION_BUILD_TESTS=OFF)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "collection" CONFIG_PATH "lib/cmake/collection")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
