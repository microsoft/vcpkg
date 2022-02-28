vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 5d5cd77e3dbb03f8e4c06289baa77bb299ab859a #v5.0.1
    SHA512 a5dafc86ac933e64eb2098916926a5d005fec1f65c4b6093a383271d86a8ed37af472fc8c84db7de1fd28408ddfbee6bc1f09de31ead571ed7722f7110701583
    PATCHES
        fix-findpackage.patch
        fix-win-build.patch
)

# The built-in cmake FindICU is better
file(REMOVE "${SOURCE_PATH}/cmake/FindICU.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        training-tools  BUILD_TRAINING_TOOLS
)

if("cpu-independed" IN_LIST FEATURES)
    set(TARGET_ARCHITECTURE none)
else()
    set(TARGET_ARCHITECTURE auto)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTATIC=${BUILD_STATIC}
        -DUSE_SYSTEM_ICU=True
        -DCMAKE_DISABLE_FIND_PACKAGE_LibArchive=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenCL=ON
        -DLeptonica_DIR=YES
        -DTARGET_ARCHITECTURE=${TARGET_ARCHITECTURE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tesseract)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tesseract/TesseractConfig.cmake"
    "find_package(Leptonica REQUIRED)"
[[
find_package(Leptonica REQUIRED)
find_package(LibArchive REQUIRED)
]]
)

vcpkg_copy_tools(TOOL_NAMES tesseract AUTO_CLEAN)

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tesseract.pc" "-ltesseract50" "-ltesseract50d")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
