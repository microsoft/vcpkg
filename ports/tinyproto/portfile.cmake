vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexus2k/tinyproto
    REF 77df8bbde4fa075031014eeef6061f2892c7b084
    SHA512 c8b1a19d45fe3527e7e16bd1641842e639e70ad3f33f804b84a3a95719ac328305a4360c9d7f6b6c5a659b01a38a50f75298467dc8c16b4d118a8ee4948ce906
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS "-DCMAKE_CXX_STANDARD=11"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tinyproto")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

