# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF 1bdc84d3bb81fa69bcf71ed5cafe63e58df1448a #v1.10
    SHA512 d7f06912a2654633e6d596805e09dbb315453837d066189091c78f7eb837a2caff1768d79f15e8b0536105ffeb67a46e7093e2d6b61091301754f4722c494ada
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/cgltf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/cgltf_write.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)