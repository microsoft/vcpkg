# Single-file header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO k06a/boolinq
    REF 1d09dc8b3df79801062e5c0e758572552fa4ce98
    SHA512 0714a97d09bb8299d39062803a8cd5de28834c372f7826afc36e17ea6aa90d2ec368d5bbb907914ad1ca5a65be41a5caeaa1583f66358577d7ea88d3c0906238
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/boolinq/boolinq.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/boolinq)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
