if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang or GCC 10+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 456b49a86dddb5949991050daa8dcfbe47ca55db6746539e14995a19bd2623ab46ac72e08af29f64cb1f3ff79265fb8d824bf9b7744f3cf94e568f27467b6185
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dglaze_DEVELOPER_MODE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
