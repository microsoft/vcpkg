include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF d374953d274131f9f295e5fdada9b9f83e208072
    SHA512 bc7d6f4d8ec8993450f415560a5f3b603f310416f54ff1f58b51554e9de7c1d8e8ed7552abfb3e51a2e711863e2e3b75169a3fd2ae7f4f79ae429797858a9faf
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
