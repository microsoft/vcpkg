include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF v2.1.0
    SHA512 6b3a3a6a9e2adff14083a8e83c95fdc5ccf0c930acff40c4cf6c11d67b0df18fd941307e5d1f0c45dcfcb4c4afd0026b718ca510a2b297b9c6be048f5b144d42
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/inja/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/inja/inja.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/inja RENAME copyright)
vcpkg_copy_pdbs()
