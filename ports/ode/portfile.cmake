vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odedevs/ode
    REF 0.16.1
    SHA512 04429cae1b8fc703e53880c5de78293cee46fe4855c96ca7006bd5848255a0df004b75716a6b30ff5176df004e2bec29b2a31d4af8e7ac59da18f0af2eed8396
    HEAD_REF master
    PATCHES
        fix-error-C3861.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DODE_WITH_DEMOS=0
        -DODE_WITH_TESTS=0
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ode-0.16.1)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/ode-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/..")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/ode-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
endif()
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_fixup_pkgconfig()
