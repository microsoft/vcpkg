vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul14
    REF a6d5612f8074f7defd08de1245fb81ca9866223b # v2.6 as first moved to GitHub
    SHA512 4b384252bf5c2fe317d4173bacc59ddc85ebe2fe104909aaf43f537a68879a69f1a271e84b9eed5c79fb1b1c351f744268e542c60c5cb5dace5cd8d1cd663408
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
