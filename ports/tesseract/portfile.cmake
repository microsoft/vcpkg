include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 3.05.02
    SHA512 4cb23a6981dd5ec9eefea7b9674847ae88a411a7308ee6d946a920c76eefcf5fe7a90f6cb3ff00493a0e69b5c327d052fa8514d7f3ed506bccbe4b0163065793
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-vcpkg-icu.patch
        ${CMAKE_CURRENT_LIST_DIR}/ws2-32.patch
        ${CMAKE_CURRENT_LIST_DIR}/leptonica.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

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
