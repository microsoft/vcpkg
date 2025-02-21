vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF v2023.06.01
    SHA512 7a231bbaf88f94c79b1ace1c3e66bd520595905bfc8a7ffa1aa453ea6f056136b82aea3a321d97db4ccfd1212a41e8790badcc43222564d861e9e5c35e40a402
    HEAD_REF master
    PATCHES
        add-algorithm.patch # https://github.com/google/breakpad/commit/898a997855168c0e6a689072fefba89246271a5d
        add-algorithm-1.patch
)

if(VCPKG_HOST_IS_LINUX OR VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_from_git(
        OUT_SOURCE_PATH LSS_SOURCE_PATH
        URL https://chromium.googlesource.com/linux-syscall-support
        REF 9719c1e1e676814c456b55f5f070eabad6709d31
    )

    file(RENAME "${LSS_SOURCE_PATH}" "${SOURCE_PATH}/src/third_party/lss")
endif()

file(COPY
        "${CMAKE_CURRENT_LIST_DIR}/check_getcontext.cc"
        "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
        "${CMAKE_CURRENT_LIST_DIR}/unofficial-breakpadConfig.cmake"
    DESTINATION
    "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" INSTALL_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DINSTALL_HEADERS=ON
)

vcpkg_cmake_install()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/client/linux/data"
    "${CURRENT_PACKAGES_DIR}/include/client/linux/sender")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            microdump_stackwalk
            minidump_dump
            minidump_stackwalk
            core2md
            pid2md
            dump_syms
            minidump-2-core
            minidump_upload
            sym_upload
            core_handler
        AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-breakpad)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
