if(VCPKG_TARGET_IS_WINDOWS)
    # Upstream's generated .def file names the DLL "pistache":
    # https://github.com/pistacheio/pistache/blob/9f4a8b365f52d4eb58db311d89161a87c1a730b6/subprojects/dump2def/dump2def.cc#L139-L144
    # They suppress the linker warning caused by the versioned DLL having a different name:
    # https://github.com/pistacheio/pistache/blob/9f4a8b365f52d4eb58db311d89161a87c1a730b6/src/meson.build#L258-L263
    # Their build also writes to Program Files, registers an event manifest, and modifies HKCU:
    # https://github.com/pistacheio/pistache/blob/9f4a8b365f52d4eb58db311d89161a87c1a730b6/src/winlog/installman.ps1#L62-L112
    message(FATAL_ERROR "Upstream's Windows build produces an unusable DLL and modifies the host system.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pistacheio/pistache
    REF "v${VERSION}"
    SHA512 2f6d3178354bd4fe78e48fbb0b15055c2a92bee4f4fcee26c3bcc2076df8ca47ef4cac931ee565f5003837beb78a2456ed7d2b6a39083860631426fd074b497c
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPISTACHE_BUILD_TESTS=false
        -DPISTACHE_BUILD_EXAMPLES=false
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
