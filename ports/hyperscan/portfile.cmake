vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HYPERSCAN_VERSION 5.4.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF v${HYPERSCAN_VERSION}
    SHA512 cfec3f43b9e8b3fbb2e761927f3a173c1230f2688da710ec7708f2941ce6f550a1d3cb48b0b0e2ccf709807390117a7e40047cb99190bcc341f37eb3da13ae62
    HEAD_REF master
    PATCHES
        0001-remove-Werror.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
