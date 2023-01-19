if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(tesseract_patch fix-depend-libarchive.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 5ad5325a0aa8effc47ca033625b6a51682f82767 #v5.2.0
    SHA512 c6ed442c9deb28772aeb918142dab08d5b55eeeeccb0c1d3f13cf51bb72af227afb7f14c19a5c8db40d6a7b8cfeccb3af08a78adfcd7431e4a06f65372709ceb
    PATCHES ${tesseract_patch}
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
        -DCMAKE_DISABLE_FIND_PACKAGE_LibArchive=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenCL=ON
        -DLeptonica_DIR=YES
        -DTARGET_ARCHITECTURE=${TARGET_ARCHITECTURE}
        -DSW_BUILD=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_OpenCL
        STATIC
        TARGET_ARCHITECTURE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tesseract)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tesseract/TesseractConfig.cmake"
    "find_dependency(Leptonica)"
[[
find_dependency(CURL)
find_dependency(Leptonica)
find_dependency(LibArchive)
]]
)

vcpkg_copy_tools(TOOL_NAMES tesseract AUTO_CLEAN)

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tesseract.pc" "-ltesseract52" "-ltesseract52d")
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
