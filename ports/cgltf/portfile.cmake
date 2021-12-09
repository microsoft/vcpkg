# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.11
    SHA512 b3350d34670dac6756ea010bd030c4709f3a6c86d43b5099d10b505437422951e5db7f8e521ec9590a7aada535146614936ff990533d07084b1e50c216572943
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/cgltf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/cgltf_write.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)