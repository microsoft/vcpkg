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
    SHA512 764dfafb7208bb18b6954103aa72aece17ee2b47a9ef32312038428551224eec6263471a6731110c64b0a8ec6850cbbc6302e8fb2b05b47a4fa14cb9d3f3febb
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
