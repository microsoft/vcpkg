
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF fdaeecbbc1bac1a417c6af2f4dab43d3840ed036
    SHA512 0d875e197bc82dd5addb8e08e9ba1a9a02e108cc9dd14e5ea17de032cda5ad599f6d10d6c7959d545e05ab30d6daa34f98061f23faeb1c15caf96b6cb76483a3
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tinyexr.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexr)
