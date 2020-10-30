# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.9.0
    SHA512 4331b64eaefe4214f00aa2679f3b18dd5d21d3870620e6809ca5f559e81ffd4df9e5f59a7fadb4dc90d1009fa2ec173b1eb69d42dd1144bac79416538a69b050
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)