if(NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "${PORT} currently only supports Linux platform.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF 9dc080b9ebbe6fc1726b45e9db1550305938313e #2021-03-31
    SHA512 b55c395fb98af85317590ed2502564af5e92e30a35618132568c6ab589a6d0971570ad20ddbd1f49d9dd8cf54692866c69cfc1350c6fdccf9efb039aacf153b4
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
