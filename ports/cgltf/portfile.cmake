# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF 093ef81bf63ec18ba6d9f61073da8881fb7619b3
    SHA512 8801c13ee98780e845c7d28b27d523af86ab2a49499bbb235ee67a91dfacda3c7fddc9503d91918001a432267f890e82c2204a9c1462c64467034d334b0eadf2
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/cgltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
