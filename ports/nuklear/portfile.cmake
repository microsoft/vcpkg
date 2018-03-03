include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF d9ccea11fe14905eba3ab4cb44207cf24345011b
    SHA512 2e21f308ed4c7888f01321f31d125b26f14e6097166ecad703d92879acc853965256c56765a682cb0be126a923726d31b165d824ea41b837901aab06b2b0e7c0
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
