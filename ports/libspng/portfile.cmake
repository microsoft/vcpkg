vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randy408/libspng
    REF v0.6.3
    SHA512 857ff6ba51d8e338b1c96a0c016aaea3aea807aaea935cc14959d3d0c337229dfb328279d042ddf937152dd0c496e5bcddbc9fa50ac167e4b31847950cc043da
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if (WIN32)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/spng.dll" "${CURRENT_PACKAGES_DIR}/bin/spng.dll")

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/spng.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/spng.dll")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
