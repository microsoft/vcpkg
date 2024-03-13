vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/packaging
    REF d563917280d65a6ce2e622bd3d07438e1ee259f3
    SHA512 eb556564096e05880413114437d857a062b12c3485f9833af5bd18a387f53b8727cf43a723e4562dacb6ed24e1e66d57978061fb474c074ceb2b287d46149e8a
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -x)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
