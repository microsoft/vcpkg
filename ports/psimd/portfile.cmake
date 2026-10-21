
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/psimd
    REF 072586a71b55b7f8c584153d223e95687148a900
    SHA512 a18faea093423dd9fe19ece8b228e011dccce0a2a22222f777ea19b023a13173966d4a8aea01147e8fc58de5d39cffcedeb2221a1572ae52bd5aba1295f86a94
    PATCHES
    add-cmake-config.patch
)   
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
