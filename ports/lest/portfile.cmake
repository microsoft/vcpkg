include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/lest
    REF v1.34.1
    SHA512 7f4b0e49c1cf4c55d21752259ee45f9265aba254b9c15f84e77f9ae3e5ef3443abcb43fafe8e16d84bbdffee72dae842de0ed661c2caeb9607fcb188eb3ec7d1
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/lest RENAME copyright)
