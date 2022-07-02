set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

# LLVM documentation recommends always using static library linkage when
#   building with Microsoft toolchain; it's also the default on other platforms
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(LLVM_ARCHIVE
    URLS "http://releases.llvm.org/7.0.0/llvm-7.0.0.src.tar.xz"
    FILENAME "llvm-7.0.0.src.tar.xz"
    SHA512 bdc9b851c158b17e1bbeb7ac5ae49821bfb1251a3826fe8a3932cd1a43f9fb0d620c3de67150c1d9297bf0b86fa917e75978da29c3f751b277866dc90395abec
)
vcpkg_extract_source_archive(LLVM_SOURCE_PATH
    ARCHIVE "${LLVM_ARCHIVE}"
    PATCHES
        llvm-001-build-only-clang.patch
)

if(NOT EXISTS ${LLVM_SOURCE_PATH}/tools/clang)
    vcpkg_download_distfile(CLANG_ARCHIVE
        URLS "http://releases.llvm.org/7.0.0/cfe-7.0.0.src.tar.xz"
        FILENAME "cfe-7.0.0.src.tar.xz"
        SHA512 17a658032a0160c57d4dc23cb45a1516a897e0e2ba4ebff29472e471feca04c5b68cff351cdf231b42aab0cff587b84fe11b921d1ca7194a90e6485913d62cb7
    )
    vcpkg_extract_source_archive(CLANG_SOURCE_PATH
        ARCHIVE "${CLANG_ARCHIVE}"
        PATCHES
            clang-001-skip-symlink.patch
            clang-002-skip-other-tool-configuration.patch
    )
    file(RENAME "${CLANG_SOURCE_PATH}" "${LLVM_SOURCE_PATH}/tools/clang")
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

set(VCPKG_BUILD_TYPE release) # we only need release here!
vcpkg_cmake_configure(
    SOURCE_PATH "${LLVM_SOURCE_PATH}"
    OPTIONS
        -DLLVM_INCLUDE_DOCS:BOOL=OFF
        -DLLVM_INCLUDE_EXAMPLES:BOOL=OFF
        -DLLVM_INCLUDE_RUNTIMES:BOOL=OFF
        -DLLVM_INCLUDE_TESTS:BOOL=OFF
        -DLLVM_INCLUDE_TOOLS:BOOL=ON
        -DLLVM_INCLUDE_UTILS:BOOL=OFF

        -DLLVM_TOOL_CLANG_BUILD:BOOL=ON

        -DCLANG_BUILD_TOOLS:BOOL=ON
        -DCLANG_TOOL_DRIVER_BUILD:BOOL=ON

        -DLLVM_USE_HOST_TOOLS:BOOL=OFF # FIXME: LLVM depends on CMAKE_CROSSCOMPILING which is incorrectly set to ON in certain cases with vcpkg 
)
vcpkg_cmake_install()

vcpkg_list(SET tools clang)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND tools clang-7)
endif()
vcpkg_copy_tools(
    TOOL_NAMES ${tools}
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/include
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/libexec
    ${CURRENT_PACKAGES_DIR}/share
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/debug/libexec
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(INSTALL "${LLVM_SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
