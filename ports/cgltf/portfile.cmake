# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF v1.13
    SHA512 b46d1f9db11b75a60eb0272e89834444cd5652fa1fa35c80ce8a78437ef1b3d9f871419cc39da2d0e021d594ffc3e3832362ec759df0a7857aa74e4639698435
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/cgltf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/cgltf_write.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)