vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gperftools/gperftools
    REF gperftools-${VERSION}
    SHA512 6ac99109d9b02afdaf31fb5ecd0bbd752a2ed59494ac7cc584944a2ebdb3254e25df2cb18a0bc1fc0e9230b967890e550cccaf92b9e59473e538977de6a133bf
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
