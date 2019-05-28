# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cbeck88/strict-variant
    REF 70cb9469b78028d72da1409d631d72a75ed7d498
    SHA512 b02bd41e69ffe15acba5fdafe7edd1b4ed3f4b57d5302b0cc904f840ad529ff72dd8f455df901bdd42d0fc3a4779cf8a518d7aa62663ea88bcd5d2893507df8d
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/strict-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/strict-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/strict-variant/copyright)
