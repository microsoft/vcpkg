
set(KERBAL_SHA_CORE                273ca690f4a2f37d933158eb8ea12823a8f9e2536b1559f49cc0a9f7ede3e252f3e3eafb1a3c0d754115b85f324f175fcb3ef6b5cb55c7b225ae90cdfcb67130)
set(KERBAL_SHA_PRETTY_PRINTER      b33b38104a640e18c9cd5c87925248e9f0d7aafdc8d5b928327ca9e32d637ba618ba6acefab61dcdcc066fe7e0908bbd2163a94f5002d12d8517e2efa6acd3ab)


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
