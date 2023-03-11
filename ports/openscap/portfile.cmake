vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenSCAP/openscap
    REF 55efbfda0f617e05862ab6ed4862e10dbee52b03 #1.3.7
    SHA512 aa38e45970c4591579fa808359d0246f19e18ecf04b69f6fdfa91047d6cea4e7369e1bdadee6c5e3e3a1a44faf5bf0ab30e2ac141a0bb745b823b8012018b3a9
    HEAD_REF dev
)
file(REMOVE "${SOURCE_PATH}/cmake/FindThreads.cmake")

if ("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        docs    ENABLE_DOCS
        tests   ENABLE_TESTS
        util    ENABLE_OSCAP_UTIL
        python  ENABLE_PYTHON3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DENABLE_PERL=OFF
        -DENABLE_MITRE=OFF
        -DENABLE_VALGRIND=OFF
        -DENABLE_OSCAP_UTIL_DOCKER=OFF
        -DENABLE_OSCAP_UTIL_AS_RPM=OFF
        -DENABLE_OSCAP_UTIL_SSH=OFF
        -DENABLE_OSCAP_UTIL_VM=OFF
        -DENABLE_OSCAP_UTIL_PODMAN=OFF
        -DENABLE_OSCAP_UTIL_CHROOT=OFF
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

#Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)