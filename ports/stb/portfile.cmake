#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF 1034f5e5c4809ea0a7f4387e0cd37c5184de3cdd
    SHA512 efc3deedd687615a6706b0d315ded8d76edb28fcd6726531956fde9bba81cc62f25df0a1f998b56e16ab0c62989687c7d5b58875789470c2bf7fd457b1ff6535
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright)

# Copy the stb header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
