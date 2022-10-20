vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenSCAP/openscap
    REF 3eccd5c064b9b152fe14a95b3534c60e003be17f #1.3.6
    SHA512 ceffe9775accc9afc69fdab07fa4112a2519d7e5366b80ec6932c6fcfad589772601ef4042d8a3389682a1fb4901d63cf586e76a8f3276251bc2d926560188d9
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