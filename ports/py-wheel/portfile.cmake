vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/wheel
    REF ${VERSION}
    SHA512 16e556272f6d47d33f2be39efc3c0882c8da90aa2945ec3574105df21ed2cb090390f7736d05a319a008f4842b3f109abea5e7607064ee80e663d499c2e67308
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

if(NOT VCPKG_TARGET_IS_WINDOWS)
  vcpkg_copy_tools(TOOL_NAMES wheel DESTINATION "${CURRENT_PACKAGES_DIR}/tools/python3" AUTO_CLEAN)
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "wheel")
