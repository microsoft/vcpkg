# 1. Install the header file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/zenith_c.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# 2. Install the license (Required by Microsoft)
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")
