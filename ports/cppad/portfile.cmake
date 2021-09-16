# the compilation fails on arm and uwp. Please check the related issue:
# https://github.com/microsoft/vcpkg/pull/12560#issuecomment-668412073
vcpkg_fail_port_install(ON_TARGET "uwp" and "arm")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF 90c510458b61049c51f937fc6ed2e611fbb17b8b #20210000.7
    SHA512 112a4663a3e13f2d852c4ce4e57f6bee2dc7584915fcbab75972568258faab0d4a5761c4eaa4c664543cb8674e8e70c0623054c07dff933f9513a47f1c7d6261
    HEAD_REF master
    PATCHES
        windows-fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dcppad_prefix=${CURRENT_PACKAGES_DIR}
    OPTIONS_RELEASE
        -Dcmake_install_libdirs=lib
        -Dcppad_debug_which:STRING=debug_none
    OPTIONS_DEBUG
        -Dcmake_install_libdirs=debug/lib
)

vcpkg_cmake_install()

# Install the pkgconfig file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/pkgconfig/cppad.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/pkgconfig/cppad.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()

# Add the copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
