vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenSCAP/openscap
    REF 3a4c635691380fa990a226acc8558db35d7ebabc #1.3.1
    SHA512 12681d43b2ce067c5a5c4eb47e14d91d6e9362b1f98f1d35b05d79ad84c7ee8c29f438eaae8e8465033155e500bb0f936eb79af46fab15e4a07e03c6be8b655d
    HEAD_REF dev
    PATCHES
        fix-build.patch
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