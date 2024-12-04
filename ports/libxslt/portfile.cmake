vcpkg_download_distfile(FIX_PACKAGE_VERSION_PATCH
    URLS https://github.com/GNOME/libxslt/commit/7504032097712714aafe309d54f2ad57e3364bac.diff?full_index=1
    FILENAME Fix-package-version.patch
    SHA512 972921decf374fe8a4cad4e09890ce0d5961ee05e3c52d117c09fe8bde1a4540ebe212e767f8a95d281945240f29a90fd15e37104f45d47440032737d41dc8d0
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxslt
    REF "v${VERSION}"
    SHA512 0974419e0eae3cd4070ca52341b3df2d1b873b30d0ede2143274fcd0ef8653d5ac55b5f0faad56d8cf60443fefb01c5f5ddecff4b7638ba28e450e88f1c3d3c4
    HEAD_REF master
    PATCHES
        python3.patch
        msvc-no-suffix.patch
        libexslt-pkgconfig.patch
        fix-gcrypt-deps.patch
        skip-install-docs.patch
        ${FIX_PACKAGE_VERSION_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python"          LIBXSLT_WITH_PYTHON
        "crypto"          LIBXSLT_WITH_CRYPTO
        "plugins"         LIBXSLT_WITH_MODULES
        "profiler"        LIBXSLT_WITH_PROFILER
        "thread"          LIBXSLT_WITH_THREADS
        "tools"           LIBXSLT_WITH_PROGRAMS
)
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}")
    list(APPEND FEATURE_OPTIONS_RELEASE "-DLIBXSLT_PYTHON_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib/site-packages")
    list(APPEND FEATURE_OPTIONS_DEBUG "-DLIBXSLT_PYTHON_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib/site-packages")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBXSLT_WITH_TESTS:BOOL=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS_RELEASE}
        -DLIBXSLT_WITH_XSLT_DEBUG:BOOL=OFF
        -DLIBXSLT_WITH_DEBUGGER:BOOL=OFF
    OPTIONS_DEBUG
        ${FEATURE_OPTIONS_DEBUG}
        -DLIBXSLT_WITH_XSLT_DEBUG:BOOL=ON
        -DLIBXSLT_WITH_DEBUGGER:BOOL=ON
    )
vcpkg_cmake_install()
file(GLOB config_path RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/libxslt-*")
vcpkg_cmake_config_fixup(CONFIG_PATH "${config_path}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/xsltConf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xsltConf.sh")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/libxslt")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/xslt-config" "${CURRENT_PACKAGES_DIR}/tools/libxslt/xslt-config")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/xslt-config" [[$(cd "$(dirname "$0")"; pwd -P)/..]] [[$(cd "$(dirname "$0")/../.."; pwd -P)]])
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/libxslt/debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/xslt-config" "${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/xslt-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/xslt-config" [[$(cd "$(dirname "$0")"; pwd -P)/..]] [[$(cd "$(dirname "$0")/../../../debug"; pwd -P)]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/xslt-config" [[${prefix}/include]] [[${prefix}/../include]])
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxslt/xsltconfig.h" "#define LIBXSLT_DEFAULT_PLUGINS_PATH() \"${CURRENT_INSTALLED_DIR}/lib/libxslt-plugins\"" "" IGNORE_UNCHANGED)
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xsltproc AUTO_CLEAN)
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h" "ifdef LIBXSLT_STATIC" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h" "ifdef LIBEXSLT_STATIC" "if 1")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxslt.pc" " -lxslt" " -llibxslt")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libexslt.pc" " -lexslt" " -llibexslt")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libxslt.pc" " -lxslt" " -llibxslt")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libexslt.pc" " -lexslt" " -llibexslt")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libxslt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright")
