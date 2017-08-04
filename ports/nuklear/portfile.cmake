include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 5c7194c2fe2c68c1a8212712c0b4b6195382d27d
    SHA512 85d8255071fb42d0a521d8d34ac579dbaa5800e96d156fa42e4ee971f1d92ea51ef3a69a166f03f3cf66b086c452892cc29457bbe4aea599c918649e87e84c38
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
