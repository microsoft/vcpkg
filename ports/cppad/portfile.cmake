# the compilation fails on arm and uwp. Please check the related issue:
# https://github.com/microsoft/vcpkg/pull/12560#issuecomment-668412073
vcpkg_fail_port_install(ON_TARGET "uwp" and "arm")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF 20200000.3
    SHA512 4e980665a21c76cf355d1c5597c65fbfba7ac3e15c43a88ccfe3ba0267b85b4e9aa7c6e8a0ed7a728f8cf2c6e1424625d5cbcdd295a6c0a08b47b4b121572d13
    HEAD_REF master
    PATCHES
        windows-fix.patch
        pkgconfig-fix.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dcppad_prefix=${CURRENT_PACKAGES_DIR}
    OPTIONS_RELEASE
        -Dcmake_install_libdirs=lib
        -Dcppad_debug_which:STRING=debug_none
    OPTIONS_DEBUG
        -Dcmake_install_libdirs=debug/lib
)

vcpkg_install_cmake()

# Install the pkgconfig file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/pkgconfig/cppad.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/pkgconfig/cppad.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
endif()

vcpkg_fixup_pkgconfig()

# Add the copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
