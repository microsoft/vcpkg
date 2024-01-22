set(LIBXDIFF_REF 77e30f3190685efd87cce2c9c5d688cbaa1b0134)
set(LIBXDIFF_SHA512 c559b575e6d6f06f3b3064f3e077a15d8f57422340199215a4cbd7beab527bc250347c8779a8d6f8c4e41799a032431e83c7336f86569527ab754444455b8c87)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Drako/libxdiff
    REF ${LIBXDIFF_REF}
    SHA512 ${LIBXDIFF_SHA512}
    HEAD_REF master
    PATCHES
        fix-usage-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_SHARED=${KEYSTONE_BUILD_SHARED}
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/xdiff.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/xdiff.dll")
    endif()
endif()


if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/xdiff.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/xdiff.dll")
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/XDiff PACKAGE_NAME XDiff)
