vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hellobertrand/zxc
    REF "v${VERSION}"
    SHA512 b674a8602c9fe26f279d913adf75b8c6d936727324a68c3e5f8a70f8cf8b499dc6c4182f324c9bb104af8c10349a74a6be3783f9a792eb75dfdcc5b857645608
    HEAD_REF main
)

# Remove vendored rapidhash to use the rapidhash port instead
file(REMOVE "${SOURCE_PATH}/src/lib/vendors/rapidhash.h")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        util ZXC_BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZXC_USE_SYSTEM_RAPIDHASH=ON
        -DZXC_NATIVE_ARCH=OFF
        -DZXC_ENABLE_LTO=OFF
        -DZXC_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zxc)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB pkgconfig_files
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzxc.pc"
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzxc.pc"
    )
    foreach(pkgconfig_file IN LISTS pkgconfig_files)
        vcpkg_replace_string("${pkgconfig_file}" "-lzxc" "-llibzxc")
    endforeach()
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Upstream installs a zxc(1) man page (and aliases) on POSIX
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

if ("util" IN_LIST FEATURES)
    # Upstream installs POSIX-only helpers next to zxc: the "unzxc" (zxc -d) and
    # "zxccat" (zxc -dc) symlinks, and the "zxcless" and "zxcgrep" shell scripts.
    # Relocate them alongside the tool (skipped on Windows).
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        file(COPY
            "${CURRENT_PACKAGES_DIR}/bin/zxcless"
            "${CURRENT_PACKAGES_DIR}/bin/zxcgrep"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        )
        foreach(helper IN ITEMS unzxc zxccat zxcless zxcgrep)
            file(REMOVE
                "${CURRENT_PACKAGES_DIR}/bin/${helper}"
                "${CURRENT_PACKAGES_DIR}/debug/bin/${helper}"
            )
        endforeach()
    endif()
    vcpkg_copy_tools(
        TOOL_NAMES
            zxc
        AUTO_CLEAN
    )
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        foreach(alias IN ITEMS unzxc zxccat)
            file(CREATE_LINK "zxc" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${alias}" SYMBOLIC)
        endforeach()
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
