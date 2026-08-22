vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanovg
    REF f93799c078fa11ed61c078c65a53914c8782c00b
    SHA512 06f55e574ac3f73f2abe6cc614e13f29d27f2e05b2a035a19084fbf69f73cc0571d808a323cd07d25f0f1cb3097bef83d10d4315999ff21d6d3c8eee494dd7fb
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/nanovgConfig.cmake" DESTINATION "${SOURCE_PATH}")

file(GLOB STB_SRCS "${SOURCE_PATH}/src/stb_*")
if(STB_SRCS)
    file(REMOVE_RECURSE ${STB_SRCS})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
