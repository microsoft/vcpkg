include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF 4fea9f2745129b3542382646d032787713667448 # v2.10
    SHA512 a6137c6c19e8b535b4794c45a988206df71fe4b91378b2bc48ab265c8e850c20b42e6556a2665fdd5e542d8d7d5109eb0421a1f47b035c6d60d0296c36bdfeb5
    HEAD_REF master
)

# Install header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctre RENAME copyright)
