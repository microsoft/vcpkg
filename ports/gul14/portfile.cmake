vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul14
    REF v2.7.1
    SHA512 d926a0475911c16900479de156e7993eb3d007738bf78b6534e84b7f95b607b374d3340e568803eff5b0dd6c119bfc38cc63d5e7c0c0c5c58f1c78c79eb7ea9e
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
