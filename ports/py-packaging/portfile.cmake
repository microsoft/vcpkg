vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/packaging
    REF ${VERSION}
    SHA512 bfffe6e677f3bdcaee87053caf5840396b694dfa771c37680282d70d62b6d928dae399a2da7f1a9ea2af482f1b61b353da0c6902d80ad932535995a8b21baabc
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "packaging")
