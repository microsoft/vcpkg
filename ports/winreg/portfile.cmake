# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF e35d0e2f7c5a9c8a502df3ae79cef0ee9308bcbc #v2.2.0
    SHA512 7883b3016475bfd386564fa0a88b570db381d1109421ca6b2318342cc8f1fb344d380ef6bd75f904c7b4084a70f6c893583a68c0bc41c027ac12ef3cfaec3476 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)