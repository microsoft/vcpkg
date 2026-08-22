vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenSCAP/openscap
    REF ${VERSION}
    SHA512 7d94ad18d456d8fcbe9f46e88d797cdd749b72cd3afd20087dc6d46aad16dfb380f667586343e7334e4d1e59d0d10cee7b5f1fac7a03598a1dd49629514cfc75
    HEAD_REF main
    PATCHES
        dependencies.diff
        install-dirs.diff
        python-win32.diff
)
file(REMOVE "${SOURCE_PATH}/cmake/FindThreads.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        crypto  VCPKG_LOCK_FIND_PACKAGE_GCrypt
        python  ENABLE_PYTHON3
        util    ENABLE_OSCAP_UTIL
)

if("python" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    vcpkg_find_acquire_program(SWIG)
    list(APPEND FEATURE_OPTIONS
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        -DVCPKG_LOCK_FIND_PACKAGE_PythonInterp=ON
        -DVCPKG_LOCK_FIND_PACKAGE_PythonLibs=ON
        "-DSWIG_EXECUTABLE=${SWIG}"
        -DVCPKG_LOCK_FIND_PACKAGE_SWIG=ON
    )
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0148=OLD
        -DENABLE_DOCS=OFF
        -DENABLE_MITRE=OFF
        -DENABLE_OSCAP_UTIL_DOCKER=OFF
        -DENABLE_OSCAP_UTIL_AS_RPM=OFF
        -DENABLE_OSCAP_UTIL_SSH=OFF
        -DENABLE_OSCAP_UTIL_VM=OFF
        -DENABLE_OSCAP_UTIL_PODMAN=OFF
        -DENABLE_OSCAP_UTIL_CHROOT=OFF
        -DENABLE_PERL=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_VALGRIND=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        -DVCPKG_LOCK_FIND_PACKAGE_ACL=${VCPKG_TARGET_IS_LINUX}
        -DVCPKG_LOCK_FIND_PACKAGE_Blkid=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_BZip2=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Cap=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_CURL=ON
        -DVCPKG_LOCK_FIND_PACKAGE_DBUS=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_GConf=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Ldap=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Libyaml=ON
        -DVCPKG_LOCK_FIND_PACKAGE_OpenDbx=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_PerlLibs=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Popt=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Procps=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Systemd=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_SELinux=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_RPM=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Popt=OFF
        -DWANT_BASE64=OFF  # clash with base64 in gsasl (transitive dep of curl)
    OPTIONS_RELEASE
        "-DPYTHON_SITE_PACKAGES_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib/site-packages"
    OPTIONS_DEBUG
        "-DPYTHON_SITE_PACKAGES_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib/site-packages"
    MAYBE_UNUSED_VARIABLES
        PYTHON_SITE_PACKAGES_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

set(scripts autotailor oscap-run-sce-script)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND scripts oscap-im)
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN LISTS scripts)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()
if(ENABLE_OSCAP_UTIL)
    vcpkg_copy_tools(TOOL_NAMES oscap AUTO_CLEAN)
else()
    vcpkg_clean_executables_in_bin(FILE_NAMES none)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
