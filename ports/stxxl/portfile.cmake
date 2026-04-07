if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

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

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_CMAKE_DIR:STRING=share/${PORT}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
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
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(TOOL_NAMES stxxl_tool AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
