vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hukkin/tomli
    REF 36ef51d6a5a55e0eca077b58695390d041061bd4
    SHA512 fe47a06dddad298dd64975f7618e7c8d03de83a8f4b44da868abd78e062138ad9df18fbc810e55e4cb240fac2c3c023b18ee4e87cab5e93cd776b34fac497bdf
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "tomli")
