set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF "${VERSION}"
    SHA512 54c1fc9d1afcec2626a7c7288609c7a0a92623476f11772c05d5177ade7313e138c8cba0128d80962d37ef86faa62796d09be40fd8fb979748bdf7f45a9ad814
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
