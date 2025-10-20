vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF "${VERSION}"
    SHA512 e66e4f192f6579128198c47ed20442dda13c741f371b447722b7449200f05785e1b69386a465febf97f33b437f6eb69b3fb282e1e9eabf6261eb7b57998cd68c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLM_BUILD_LIBRARY=ON
        -DGLM_BUILD_TESTS=OFF
        -DGLM_BUILD_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/copying.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
