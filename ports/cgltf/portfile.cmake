# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.10
    SHA512 a3c442e99f9c94762b4c49df2e18dcc0d38aebe785ad55717a1db73b3b2e72c1c7c90d96a21e82bd1ae9f42e8187d262e7442e7506ced9f9227a6edcc6ce4c01
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/cgltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/cgltf_write.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
