vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sass/sassc
    REF 3.6.2
    SHA512 fff3995ce8608bdaed5f4f1352ae4f1f882de58663b932c598d6168df421e4dbf907ec0f8caebb1e56490a71ca11105726f291b475816dd53e705bc53121969f
    HEAD_REF master
    PATCHES remove_compiler_flags.patch
)

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

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{LIBS} "$ENV{LIBS} -lgetopt")
endif()
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${HOST_OPTION}
        ${BUILD_OPTION}
    OPTIONS_DEBUG
        --with-libsass='${CURRENT_INSTALLED_DIR}/debug'
    OPTIONS_RELEASE
        --with-libsass='${CURRENT_INSTALLED_DIR}'
)
vcpkg_install_make(MAKEFILE GNUmakefile)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)