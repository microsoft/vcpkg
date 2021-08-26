# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.8
    SHA512 d77064bf333b7d1cbc91e261f375f1fdd60934aeb3cf87f1121cf4c4ae294532885381a265f4380c79d6bc75de72ed5f3e57153c5d0d0db98a65ee14f8b1bbfe
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/cgltf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/cgltf_write.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
