vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO linux-audit/audit-userspace
        SHA512 297664a55ab44b40c9280202c19612cfbfdacc209c4d226461ea5faa638e35617cb516e53d1f0bc3748cdd038d9524f3e5ebe11c8de4a5511ab4f12b7d06478c
        REF v4.0.1
        HEAD_REF master
        PATCHES
        0000-add-missing-unistd-include.patch
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
        "\t- <autoconf>\n"
        "\t- <automake>\n"
        "\t- <libtool>\n\n"
        "It can be installed with your package manager"
)

message(STATUS "Check: ${PORT} C compiler: ${CMAKE_C_COMPILER_ID}")
message(STATUS "Check: ${PORT} CXX compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Fixup: README requirements: ${SOURCE_PATH}/README.md -> ${SOURCE_PATH}/README")
file(TOUCH "${SOURCE_PATH}/README")

vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
        --with-python3=no
        --with-golang=no
        --with-io_uring=no
        --with-warn=no
        --disable-zos-remote
)

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
