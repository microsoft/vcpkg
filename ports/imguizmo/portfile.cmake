vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CedricGuillemet/ImGuizmo
    REF ${VERSION}
    SHA512 23285398688b4cdf3128ecb918b70c9a52f06c8e911da57430442b838cecf653e233d8cdfefc6acd3e4da381869ffc6fb74bcaaafc8e33657d6060a645517363
    HEAD_REF master
    PATCHES
        fix-build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DIMGUIZMO_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
