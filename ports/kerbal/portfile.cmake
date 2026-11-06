
set(KERBAL_SHA_CORE                4ccb5a7bd7aa540e1087135882176bbda2d4ba19e5a861d4e1377b266723e371d0aa50cd2ce1d5d65be0921bd4f0204efd6c507ad02f203082688baf7ae739d3)
set(KERBAL_SHA_PRETTY_PRINTER      16acd40f3a0d7f818506dc618da390bda02e45318ed1764b6d387e0a0dfa2578c3900c1233137278c23797a801a6c3a9e69e38ae30fcf8181b1ecf61f52da5e0)


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
