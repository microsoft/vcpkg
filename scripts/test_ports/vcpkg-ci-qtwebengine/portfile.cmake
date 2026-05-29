SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(EXISTS "${CURRENT_INSTALLED_DIR}/share/Qt6Pdf/Qt6PdfTargets.cmake")
    file(COPY_FILE "${CURRENT_INSTALLED_DIR}/share/Qt6Pdf/Qt6PdfTargets.cmake" "${CURRENT_BUILDTREES_DIR}/Qt6PdfTargets.cmake-${TARGET_TRIPLET}.log")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DFEATURES=${FEATURES}"
)

vcpkg_cmake_build()
