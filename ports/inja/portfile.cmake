include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF v2.1.0
    SHA512 1
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/inja/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/inja/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/inja RENAME copyright)
vcpkg_copy_pdbs()
