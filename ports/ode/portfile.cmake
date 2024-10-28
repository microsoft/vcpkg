vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odedevs/ode
    REF ${VERSION}
    SHA512 683869e6c7a39ea8dc6666b47633199111d1c0f2516cacb534ec57f6025a5780d85b2e59095a736790662280e4e4c9a2cd44b2cafaa34669e6861cce5b32e76b
    HEAD_REF master
    PATCHES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DODE_WITH_DEMOS=0
        -DODE_WITH_TESTS=0
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ode-${VERSION})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/ode-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/ode-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_fixup_pkgconfig()
