# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF 1d60c7f3004a87eaa9d9cbd647d66361c868558f
    SHA512 4b435843291f4db5be6d3fb3dd33c38a1c3c0a2e2c22910b819f119cfca2867116c5d01dd5e7d302693d467821688aac5dc7334b4a9ef39275e682f1fb99585c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrentqueue RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
