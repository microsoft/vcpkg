# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/lazy_importer
    REF a02a9ed62ea56c614728465b1be9fab812fdf037
    SHA512 d88a7a1df269f2159eb0997f691fb5b71e89d75160b45ce968bd58e0d71e214f03e4c05e44234ace04ba9025b0b7d3ff07cf803753473c51164223a05a61598f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/lazy_importer.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
