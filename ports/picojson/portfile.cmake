vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kazuho/picojson
    REF v1.3.0
    SHA512 76d5a6b3b9e1151198eee707faffcbbba28a2842daccf03d99a5d02ae017f9517ef3ac9da4acc74a4fc1357feaf19e14a15c34698a1d4cb65acb6d23b566b284
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/picojson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
