vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gperftools/gperftools
    REF gperftools-${VERSION}
    SHA512 0373053d1a67684a8a8c47818f3e4a5ad8f88993107868a1d90305a401c54e6ca94bde4dc5187bfce8cfc99e98e04ac72f3e2894806160a4dca006b6c86ba215
    HEAD_REF master
    PATCHES
        libunwind.diff
        install.diff
        win32-override.diff
)

if("override" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        libunwind   gperftools_enable_libunwind
        override    GPERFTOOLS_WIN32_OVERRIDE
        tools       GPERFTOOLS_BUILD_TOOLS
)

if(gperftools_enable_libunwind)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        -Dgperftools_build_benchmark=OFF
        ${OPTIONS}
    OPTIONS_DEBUG
        -DGPERFTOOLS_BUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        GPERFTOOLS_BUILD_TOOLS
        GPERFTOOLS_WIN32_OVERRIDE
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB gperf_public_headers "${CURRENT_PACKAGES_DIR}/include/gperftools/*.h")
    foreach(gperf_header IN LISTS gperf_public_headers)
        vcpkg_replace_string("${gperf_header}" "__declspec(dllimport)" "")
    endforeach()
endif()

if("tools" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_copy_tools(TOOL_NAMES addr2line-pdb nm-pdb AUTO_CLEAN)
    endif()
    # Perl script
    file(INSTALL "${SOURCE_PATH}/src/pprof" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
