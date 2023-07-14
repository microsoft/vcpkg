if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charles-lunarg/vk-bootstrap
    REF "v${VERSION}"
    SHA512 357ce69b080c6abcef7764652f5ab5e5fc744a9d0308bf457787f27c3c14a911480a7f9caf304ee92c33519bfbc977fb320fa3ef4a329716d0bd1b03135dd98e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # This option will disable build tests and example, and next release this option need to change as -DVK_BOOTSTRAP_TEST=OFF. The related upstream commit: https://github.com/charles-lunarg/vk-bootstrap/commit/4ae9513ff9182b9c519504a73435ed575a821300.
        -DCMAKE_PROJECT_NAME=
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vk-bootstrap-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
