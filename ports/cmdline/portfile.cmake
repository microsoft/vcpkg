vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tanakh/cmdline
    REF master
    SHA512 4d16185c9d8a75a90f21063580301a837bfbb40d9d2aae1449243d5dcbd1d32ea78701ee0c9b74b8e527cc9d36e9397023f08a9dd3d96a55acec9fbcf532a635
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmdline)

file(INSTALL ${SOURCE_PATH}/cmdline.h
     DESTINATION ${CURRENT_PACKAGES_DIR}/include)
