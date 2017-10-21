include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chemeris/msinttypes
    REF 7636cabe55318824dc702d15b69711f5d7c30250
    SHA512 1c3c350d12c6b69e1cb6469f742afc126d50fd92e137ecacdb8367e320350cd42d7d41fbb0aa38d6a13aefbef5308f9ec89825e9b80a932f552a889f63b35cb2
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/inttypes.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/msinttypes)
file(INSTALL ${SOURCE_PATH}/stdint.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/msinttypes)
file(INSTALL ${SOURCE_PATH}/stdint.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/msinttypes RENAME copyright)
