# ports/webcraft/portfile.cmake
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adityarao2005/WebCraft   # <--- CHANGE THIS to your actual User/Repo
    REF 0294f663255271b328da8f8643489ba9e91b6845                         # <--- The tag/commit you want to release (can be empty if only using --head)
    SHA512 65a1ffbd07770d02083e1fd61152ca50b1f203f423199daa7d5d8a960a6ee12c7f1ba11df876eef0a78e419c4ec2a073c05f10396d46db98d309a0e24a8b0fb1
    HEAD_REF main                      # <--- The branch to use when building with --head
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWEBCRAFT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME WebCraft 
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
