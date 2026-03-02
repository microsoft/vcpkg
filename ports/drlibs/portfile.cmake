# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF 5690d4671d7ad07ae6021756d7222eb159745f06
    SHA512 4f49024b219f160f12b24fbabd3aa3886bc76ca431b042e1d35812298b615e025f88af6df76ea4cf2e8b440cbbfaab65babb0fe880d240bd6bb354e2534bb64f
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
