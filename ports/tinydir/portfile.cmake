include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cxong/tinydir
    REF 1.2.3
    SHA512 fa366525558b0932994f93bab7a9edafdc7fe297fc65c2ce8af5b4b05c33c4af4b1fdf72292a7a89dcea4276cf419e3569e41ff1122e0048ad467ed6e33836a2
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/tinydir.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinydir RENAME copyright)
vcpkg_copy_pdbs()
