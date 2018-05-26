include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF ba5485cb56329db3ea3f5402ef596d3b512b903a
    SHA512 8aa66e3e1a2b7c544d9d105ad9f803119791b971cce4dff63ae47b63a08fd422fc75108aeb69300fa9982568d689f506456c6f8ed7287a19b9ed84649fad9315
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()