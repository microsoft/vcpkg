#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF b777360d73c10a367d268a8bb51bc0d1f36020b5
    SHA512 65d2c01ea72868e1212dc5af6b8bad7603a40e030a6c6ee59ae4e723de9c974ed31385475e2bcf0f22d424666fc70c7851c3998d0c51afc845785e71ed267a8f
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/drlibs)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/drlibs/README.md ${CURRENT_PACKAGES_DIR}/share/drlibs/copyright)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
