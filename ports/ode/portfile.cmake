vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odedevs/ode
    REF ${VERSION}
    SHA512 c9160d9b7419c74c700d9efe5cdb82e70cab867a10f03fe8b99c32ed946ee4ecb50e055a6c11495dd9ed4754110ef0d071fbcfbf4cc6b67841607ed90b1ce35b
    HEAD_REF master
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
