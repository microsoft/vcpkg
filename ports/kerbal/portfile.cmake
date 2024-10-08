
set(KERBAL_SHA_CORE                cf9830a6b6696c556bc2ed64a42db2dfc1fae2057f170c479db58bf5ced96c68bb999cdf02e8466fa983391e0b4bdebc8d1f7bc3830a5e9365c8145ff29928c1)
set(KERBAL_SHA_PRETTY_PRINTER      78f512c55bce9c2d60cdb34d0e64088b4d613340d0e26757b3db1bf50c3586008f0456a386a90626a43b844b66e37f914dbc48dcf5a53381c89f8b4500b849fb)


vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO WentsingNee/Kerbal
        REF "v${VERSION}"
        SHA512 "${KERBAL_SHA_CORE}"
        HEAD_REF main
)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            "pretty-printer"       WITH_PRETTY_PRINTER
)

if (WITH_PRETTY_PRINTER)
    vcpkg_from_github(
            OUT_SOURCE_PATH SOURCE_PATH_PRETTY_PRINTER
            REPO WentsingNee/KerbalPrettyPrinter
            REF "v${VERSION}"
            SHA512 "${KERBAL_SHA_PRETTY_PRINTER}"
            HEAD_REF main
    )
    file(GLOB pretty_printer_files
            LIST_DIRECTORIES True
            "${SOURCE_PATH_PRETTY_PRINTER}/*"
    )
    foreach (e IN LISTS pretty_printer_files)
        file(
            COPY "${e}"
            DESTINATION "${SOURCE_PATH}/pretty_printer"
        )
    endforeach ()
endif ()

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        CONFIG_PATH "share/cmake/Kerbal"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
