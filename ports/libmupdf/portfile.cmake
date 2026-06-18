if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # incomplete DLL exports
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF "${VERSION}"
    SHA512 c0f802fd2b181587df1748a8db7163bbcd3951b943d1321afcff56fccb515dfe99061288bc691323d0854305a1d4205c99457954b10439adb122975429cbce72
    HEAD_REF master
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-libmupdf-config.cmake.in" DESTINATION "${SOURCE_PATH}")

# 1.26.10 lacks bin2coff arm64 changes in host tool.
vcpkg_download_distfile(BIN2COFF_C
    URLS "https://github.com/ArtifexSoftware/mupdf/raw/9c1af80cea03987b147b0dffd944075f3b3cf4cb/scripts/bin2coff.c"
    FILENAME "ArtifexSoftware-mupdf-bin2coff-9c1af80.c"
    SHA512 9f0e70cc0ade3a39c46425d968ff6493d47f36b9bfef2efbb0ae62aef29f71952690ab9716084c0161c7184cd654abc57c2b2f6a4cc3f9e184863e7bb7b64f52
)
file(COPY_FILE "${BIN2COFF_C}" "${SOURCE_PATH}/scripts/bin2coff.c")

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
