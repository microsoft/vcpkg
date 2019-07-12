include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 5280bbcade4e2dec5eef439a6e189504c2eadcd9
    SHA512 1d000cbf368863e86a81304c832c5f8c7bdecfb08d19d92d074e783acd532508239189c31a17020645c97fc4f83fabdde23b68c4d8c83a0ea6f0564eb5e65aac
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
set(EXTENSION)
if(WIN32)
    set(EXTENSION ".exe")
endif()
file(COPY ${CURRENT_PACKAGES_DIR}/bin/tesseract${EXTENSION} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tesseract)
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
