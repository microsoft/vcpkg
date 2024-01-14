vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF v2023.01.27
    SHA512 c6802c55653289780232b20e2abc0458c49f3cdff108c3ddfd6e40a2f378da34adbc158548e9c88cbfdbba9526477da9b68c2c45e205231e2802fe533b6bd6a4
    HEAD_REF master
    PATCHES
        fix-const-char.patch
        fix-unique_ptr.patch
)

if(VCPKG_HOST_IS_LINUX OR VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_from_git(
        OUT_SOURCE_PATH LSS_SOURCE_PATH
        URL https://chromium.googlesource.com/linux-syscall-support
        REF 7bde79cc274d06451bf65ae82c012a5d3e476b5a
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
