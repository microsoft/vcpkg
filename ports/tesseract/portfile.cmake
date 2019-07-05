include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 4.0.0
    SHA512 69e57d4ba1fc43d212fd0fff69a2b5d48a3b37cfee7054fdc083cbb7e04d92317609a32e457229661d70ce8d9b16c9d25e81bfc3861db660dd2c8f292202d447
    HEAD_REF master
    PATCHES
        use-vcpkg-icu.patch
        ws2-32.patch
        leptonica.patch
)

# The built-in cmake FindICU is better
file(REMOVE ${SOURCE_PATH}/cmake/FindICU.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC=ON
        -DUSE_SYSTEM_ICU=True
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

# Install tool
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/tesseract)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/tesseract.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tesseract)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/tesseract)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tesseract)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tesseract/LICENSE ${CURRENT_PACKAGES_DIR}/share/tesseract/copyright)
