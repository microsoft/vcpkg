vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stxxl/stxxl
    REF b9e44f0ecba7d7111fbb33f3330c3e53f2b75236
    SHA512 800a8fb95b52b21256cecb848f95645c54851f4dc070e0cd64fb5009f7663c0c962a24ca3f246e54d6d45e81a5c734309268d7ea6f0b0987336a50a3dcb99616
    HEAD_REF master
    PATCHES
        # This patch can be removed when stxxl/stxxl/#95 is accepted
        fix-include-dir.patch
        0001-fix-visual-studio.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_EXTRAS=OFF
        -DUSE_BOOST=OFF
        -DTRY_COMPILE_HEADERS=OFF
        -DUSE_STD_THREADS=ON
        -DNO_CXX11=OFF
        -DUSE_VALGRIND=OFF
        -DUSE_MALLOC_COUNT=OFF
        -DUSE_GCOV=OFF
        -DUSE_TPIE=OFF
    OPTIONS_DEBUG
        -DSTXXL_DEBUG_ASSERTIONS=ON
    OPTIONS_RELEASE
        -DSTXXL_DEBUG_ASSERTIONS=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/stxxl-config.cmake"
    "\${STXXL_CMAKE_DIR}/../include"
    "\${STXXL_CMAKE_DIR}/../../include"
)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/stxxl_tool${EXECUTABLE_SUFFIX}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin"
)

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE_1_0.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
