vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF 689a25aae9171b3ea46bd80d4189f540f35f1a02
    SHA512 a1d3521b3458c791eb1242451b4eaafda870f68b5baeb359549eba10ed69ca417eeaaac95fd0d48350852661af7688c6b640361e9f70af57ae24d261c4ac0b85
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_build_cmake(ADD_BIN_TO_PATH)

# Headers
file(
    INSTALL ${SOURCE_PATH}/util
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    FILES_MATCHING
    PATTERN "*.hh"
    PATTERN "*.h"
)
file(
    INSTALL ${SOURCE_PATH}/lm
   DESTINATION ${CURRENT_PACKAGES_DIR}/include
   FILES_MATCHING
   PATTERN "*.hh"
    PATTERN "*.h"
    PATTERN "*test_data*" EXCLUDE
)
# Copyright and License
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)

vcpkg_copy_pdbs()
