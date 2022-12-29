vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO lu-zero/mfx_dispatch
        REF 1.35.1
        SHA512 12517338342d3e653043a57e290eb9cffd190aede0c3a3948956f1c7f12f0ea859361cf3e534ab066b96b1c211f68409c67ef21fd6d76b68cc31daef541941b0
        HEAD_REF master
        PATCHES
            fix-unresolved-symbol.patch
            fix-pkgconf.patch
)

set(LIBRARY_TYPE ${VCPKG_LIBRARY_LINKAGE})
if (LIBRARY_TYPE STREQUAL "dynamic")
    set(LIBRARY_TYPE "shared")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}" 
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
  
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
