include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 3.05.01
    SHA512 a49c20c98386684cd89582e57b772811204fad8e5ff18214fb0da109f73629c70845054985e31e8deeb49107fbcf56e546aff661f08eb5dd60fbf83dbe976e81
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-vcpkg-icu.patch
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
