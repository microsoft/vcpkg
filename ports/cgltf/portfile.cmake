# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.3
    SHA512 4fc68654b7903a21156d900184626d1325421092f0dd060b9f20cff1dec29d0a057fc1f3b4e79e36a0cfc6bc7447f7c2ac8a0ecb78c85a337356908a9c69478e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/cgltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
