vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/GKlib
    REF 3eabb216ac97e11ce7e7a9b90f4c90778d9e7c18 #v5.1.1
    SHA512 1359ec14357419e3f5fea1fab8e9edf4aee214078ea8401405edb67b92b56254048a39b7a264ad3feb30dceb99cf110168d869126396d8adef1c023f8f1de5e9
    HEAD_REF master
    PATCHES fix-CMakeExport.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-gklib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
