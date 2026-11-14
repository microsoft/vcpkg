if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # incomplete DLL exports
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF "${VERSION}"
    SHA512 b09fd538670fd22e008238b8bfe056960ac60cb018f69bd2119c2a8eff4159d3239bca82f10f5620489a619113ed209f10160fd6090ebdb64bf3f2fd717d119e
    HEAD_REF master
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-libmupdf-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        ocr ENABLE_OCR
)

if(VCPKG_CROSSCOMPILING AND VCPKG_HOST_IS_WINDOWS AND VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-DBIN2COFF_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/bin2coff.exe")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-libmupdf")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/manual-tools")

set(font_licenses "")
foreach(item IN ITEMS urw/OFL.txt noto/COPYING han/LICENSE.txt droid/NOTICE sil/OFL.txt)
    string(REPLACE "/" " " new_name "# Fonts - ${item}")
    set(file "${CURRENT_BUILDTREES_DIR}/${new_name}")
    file(COPY_FILE "${SOURCE_PATH}/resources/fonts/${item}" "${file}")
    list(APPEND font_licenses "${file}")
endforeach()

vcpkg_install_copyright(
    # Cf. source/fitz/noto.c
    COMMENT [[
This software includes Base 14 PDF fonts from URW, Noto fonts from Google.
Source Han Serif from Adobe for CJK, DroidSansFallback from Android for CJK,
Charis SIL from SIL.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        ${font_licenses}
)
