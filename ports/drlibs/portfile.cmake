# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF 80bc8919291e4751edfb4e541363c0f30a7cc6a6
    SHA512 f74e828d5caf9dbe0e1a30abc6327909997e00ea62eadbefcb3d207a0f1d473cf92f8aedff3cd83797066287523cdf147dac8088087c7dbc2dc29a7008497b45
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
