vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 4.1.1
    SHA512 017723a2268be789fe98978eed02fd294968cc8050dde376dee026f56f2b99df42db935049ae5e72c4519a920e263b40af1a6a40d9942e66608145b3131a71a2
    PATCHES
        fix-tiff-linkage.patch
        fix-timeval.patch # Remove this patch in the next update
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

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

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

if("training-tools" IN_LIST FEATURES)
    list(APPEND TRAINING_TOOLS
        ambiguous_words classifier_tester combine_tessdata
        cntraining dawg2wordlist mftraining shapeclustering
        wordlist2dawg combine_lang_model lstmeval lstmtraining
        set_unicharset_properties unicharset_extractor text2image
    )
    vcpkg_copy_tools(TOOL_NAMES ${TRAINING_TOOLS} AUTO_CLEAN)
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
