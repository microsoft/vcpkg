
set(KERBAL_SHA_CORE                9cf05d4901ba2b99d6801e75973e773e28b4ccd019a46a140ae733d14675ce9de29641a9d81c163e34cf0900ac9ab1724f8d678a6e96d4eb11c4a2ef007e9ae9)
set(KERBAL_SHA_PRETTY_PRINTER      af34cc5e8dcd37aa911151c47a7a38de2709ca4e9c83ef5809f6540b1dc3b6e352317ebb806eb28b5739339756fb2e22cfe923585bc64107126a5db67e12fc96)


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
