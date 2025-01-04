vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenSCAP/openscap
    REF ${VERSION}
    SHA512 10f28593a6776d28020c26fc3ad3f3aa095fdc48fa6261c0b9677c559d3c822a23eb61c02e09a3c11654dc20d8374b5fcc3154bb9d2d34da5985fc737d252a9b
    HEAD_REF dev
    PATCHES
        fix-build.patch
        fix-buildflag-and-install.patch
        fix-utils.patch
        fix-dependencies.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/FindThreads.cmake")

if ("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        util    ENABLE_OSCAP_UTIL
        python  ENABLE_PYTHON3
)

if(VCPKG_TARGET_IS_LINUX AND ENABLE_OSCAP_UTIL)
     message("openscap with util feature requires the following packages via the system package manager:
  libgcrypt20-dev
On Ubuntu derivatives:
  sudo apt install libgcrypt20-dev")
endif()

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
        -DENABLE_TESTS=OFF
        -DENABLE_DOCS=OFF
        -DWANT_BASE64=OFF
)

vcpkg_cmake_install()
if(ENABLE_OSCAP_UTIL)
    vcpkg_copy_tools(TOOL_NAMES oscap AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

#Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
