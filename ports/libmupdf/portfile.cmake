if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mupdf-1.11-source)
vcpkg_download_distfile(ARCHIVE
    URLS "https://mupdf.com/downloads/mupdf-1.11-source.tar.gz"
    FILENAME "mupdf.tar.gz"
    SHA512 501670f540e298a8126806ebbd9db8b29866f663b7bbf26c9ade1933e42f0c00ad410b9d93f3ddbfb3e45c38722869095de28d832fe3fb3703c55cc9a01dbf63
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

#copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYRIGHT)
