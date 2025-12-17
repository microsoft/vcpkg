vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gperftools/gperftools
    REF gperftools-${VERSION}
    SHA512 c6f68c307f7ecc5a3ff49b616155cb6d5bcc8e7a14b52f480a4e7e6deed562e988af549cd6b3d6f9150d92561947460a2a97d3355c73b81a4d0414870c0b7d32
    HEAD_REF master
    PATCHES
        libunwind.diff
        install.diff
        win32-override.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/googletest")

if("override" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        libunwind   gperftools_enable_libunwind
        override    GPERFTOOLS_WIN32_OVERRIDE
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
    MAYBE_UNUSED_VARIABLES
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
