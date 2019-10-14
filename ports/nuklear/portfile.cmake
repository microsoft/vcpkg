include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 5fa99df235e50aef82e7757002099ead7a1395fe
    SHA512 d0be03e891e4efbc54ef97e2fd8721071227b8aed17d4a57cc4aab4023975f7bf33710a864041a60d2375e3eb8f65cb2ea6255d83db874dcd21e0450ff2f5e5c
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
