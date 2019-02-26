# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/readerwriterqueue
    REF v1.0.0
    SHA512 3bb8320e35e8911350df1bd5349e006f85cbd0863cc2bb8ac1912aaf7a5686f42966b7508a845cfdca280ab65a308148315c987ef333d74b6d085638dd6d8578
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/readerwriterqueue RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
