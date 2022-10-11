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
    PATCHES stream-handler-executor.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCPP-NETLIB_BUILD_TESTS=OFF
        -DCPP-NETLIB_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/cppnetlib)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cppnetlib TARGET_PATH share/cppnetlib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
