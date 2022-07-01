vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sass/libsass
    REF 3.6.5
    SHA512 98CC7E12FDF74CD9E92D8D4A62B821956D3AD186FCEE9A8D77B677A621342AA161B73D9ADAD4C1849678A3BAC890443120CC8FEBE1B7429AAB374321D635B8F7
    HEAD_REF master
    PATCHES remove_compiler_flags.patch
)

# `--host` option is needed for cross-compiling on linux, to select the correct toolchains,
# instead of using the detected native toolchains, which would cause failure. To avoid this,
# we can specify the corresponding toolset to `VCPKG_TOOLSET_PREFIX` in the target triplet.
# For example, while cross-compiling for arm64, we can specify `aarch64-linux-gnu` to 
# `VCPKG_TOOLSET_PREFIX` variable in a target triplet file.
if(VCPKG_HOST_IS_LINUX)
    execute_process(COMMAND "uname" "-m" OUTPUT_VARIABLE HOST_SYSTEM_PROCESSOR OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(BUILD_OPTION --build=${HOST_SYSTEM_PROCESSOR}-linux-gnu)
    if(DEFINED VCPKG_TOOLSET_PREFIX)
        # Give a change to select an alternative toolset by user.
        set(--host=${VCPKG_TOOLSET_PREFIX})
    else()
        message(NOTICE
            "\nAutomatically select building toolset for ${VCPKG_TARGET_ARCHITECTURE}. "
            "VCPKG_TOOLSET_PREFIX can be set in the triplet file to use specific toolset."
            " Like for arm64:\n    set(VCPKG_TOOLSET_PREFIX aarch64-linux-gnu)\n"
        )
        # Select propriate toolset according to VCPKG_TARGET_ARCHITECTURE
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            set(HOST_OPTION --host=arm-linux-gnueabihf)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(HOST_OPTION --host=aarch64-linux-gnu)
        endif()
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${HOST_OPTION}
        ${BUILD_OPTION}
)
vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
