vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF c2a3efe2824e1c8a0810e82a43406ba8e01527c4 #5.1.0
    SHA512 a9a6a2d49d5e4aa10b48d45e8334c70e370d4e22418ae1fed55a29f6523790c2e1ec96c54f0ba110bf0358cd111bda5291d165aa7f66c51f229c9c70876c72ee
    PATCHES
        #fix-tiff-linkage.patch
        #fix-timeval.patch # Remove this patch in the next update
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
        -DSW_BUILD=OFF
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tesseract.pc" "-ltesseract41" "-ltesseract41d")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
