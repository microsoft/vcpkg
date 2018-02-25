include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 45193dc6ddf1473b6e37dfd6b0c1813d5b52e09b
    SHA512 f02c1b3b9eeea1a257a43006ec90159d6a8aa830d506133281fd52f9be1bcfef6b0f3ecad7dbad8a7480e4ae530a502b5bf8a50d51892b948f0a814103e66069
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
