# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.2
    SHA512 3a678023ffd25416a1454da5e67bdf303d08dcd5a46e19a912dc2dfc549a6cd5800024649757c19653f9b2763fc6342d8dd398e940b2df6c3e1b222a4fd2e0e1
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/cgltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
