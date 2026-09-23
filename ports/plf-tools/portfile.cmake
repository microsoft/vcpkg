set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_tools
    REF 52f9bc70ad4d435f055fde8f22a3b6d9a227e44c
    SHA512 87450933f62acfe49822d156cde2ca59bafc7501beba1dba805a63d5a040d4af77f584e186fb7538659befb601d195a5bba3e37d10dab9714848efe05a7409b5
    HEAD_REF main
)

file(
    COPY
        "${SOURCE_PATH}/plf_tools.h"
        "${SOURCE_PATH}/plf_tools_undef.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
