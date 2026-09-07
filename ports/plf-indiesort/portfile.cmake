set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_indiesort
    REF 23d3fb6e1f738d9ec6e05bd9e20a8d1f55df9eed
    SHA512 42f468cbe948fee697f01e1547baed899cc55024ab28cc793dab0530c36faa08ca48011395c70d06e8d03c8e766dcaf87fee36cd2c611c8eb19f678cb917dd7b
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_indiesort.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
