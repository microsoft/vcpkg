# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/lazy_importer
    REF 88186bfce98845eba9050f7597332754f621c0fc
    SHA512 04789501ea9c9cf600326b3f8292c441f54d0915452eb29b063fe0a8d56a31157cf338a4ec44aa658e397d754b6593ece51af2736d5980e72d67359a1abc2625
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/lazy_importer.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
