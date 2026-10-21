if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mamba-org/libcred
    REF ${VERSION}
    SHA512 77470b552cafc2506f9f1be56a2cd7aa412a4b568120037bf730273b5cc7c4dbabebb0abb6b192e3aef69912c6b5721d9e80b0cae0059f4fe814a5c0a8f3dcfb
    HEAD_REF main
    PATCHES
    disable_tests.patch
)

vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_install_meson()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
