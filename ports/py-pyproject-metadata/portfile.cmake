vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FFY00/python-pyproject-metadata
    REF ${VERSION}
    SHA512 8d8c7839a318acce64b0cf15b3adbc49c2f309b453135b55f2d7942967ba8bbd4f85696d0f3c651e1246c50e33657e6108f0f05ac20b4a9162cdb2875269c548
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "pyproject_metadata")
