include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tronkko/dirent
    REF 8b1db5092479a73d47eafd3de739b27e876e6bf3
    SHA512 f529aa65c2a4b8249c1291f3bccad25fa3a9c2146a2c74abc0a4710f68e2bd6f73cd52682bb406fbcab71d6a5225a354f9e8bdc22ce63b7a4e64bb65bab34b9f
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/dirent RENAME copyright)
vcpkg_copy_pdbs()
