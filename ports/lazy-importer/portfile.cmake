# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/lazy_importer
    REF 4810f51d63438865e508c2784ea00811d9beb2ea
    SHA512 1b2f330586cb80d8ecf13dd27c5a407c778c3a12aeffa493d31b75fa9c3186ed9f67838164c48c64e2bb4a9fe804a77625dd1cd996d661545580e29d57c3494b
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/lazy_importer.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
