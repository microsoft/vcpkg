vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-netlib/cpp-netlib
    REF 31d304cdf52b485f465ada433d8905171b61cbff
    SHA512 6d157e6d950dd76a6d16b9c13d4d29f188d9f540eb0b44ab169016e1d7a360995e51d9923b532503a17dd2c8e0e2a38b2f9b531db03b33239e7fb9ca4d047b0c
    HEAD_REF master
    # Updator's note: cpp-netlib has many templates that are not fully instantiated when not building examples.
    # This patch specifically fixes one of those issues
    # To test updates, enable building examples below (may also require patching out uses of cxxopts)
    PATCHES
        fix-compatibility-with-boost-1.83.patch
        stream-handler-executor.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP-NETLIB_BUILD_TESTS=OFF
        -DCPP-NETLIB_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME cppnetlib)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cppnetlib PACKAGE_NAME cppnetlib)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
