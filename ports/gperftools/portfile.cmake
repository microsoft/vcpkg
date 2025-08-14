vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gperftools/gperftools
    REF gperftools-${VERSION}
    SHA512 abddaa4e5ff12a468add0db801f8473b8ce2316ca0b229ac9dbea3d528a30a47db4a825e7c4213dd8666b1a4555b3b31ba22ec43014ae5142b35c70010171df1
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
