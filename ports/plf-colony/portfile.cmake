set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 207cfda6168e866e64fdc015a2aced8000c3af66
    SHA512 c58fdf8af149a6cda0d0f8b584e2fe21496101c6015a34fdaa98b86e281e0cc58b99e23dc72f6108314959a7a59578a8557dd80844777264a10241a1444dae34
    HEAD_REF master
)

# Do not copy "plf_tools.h" and "plf_tools_undef.h" here - they get installed
# via plf-tools to avoid conflicts other ports of the same maintainer
file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
