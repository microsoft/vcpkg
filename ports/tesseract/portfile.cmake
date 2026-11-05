vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF "${VERSION}"
    SHA512 c55ad36af09f4ba48df2f32a3e2413764aeee330f5f5468e92be59572fd90b388f0ea3cb7dc0cc89c21ff68f76cd0baaee1ca0a45e648dc8f4819aefdc2749c2
    PATCHES
        fix_static_link_icu.patch
        fix-link-include-path.patch
        target-curl.diff
        fix-msvc-training-tools.patch # tesseract-ocr/tesseract#4590
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        training-tools  BUILD_TRAINING_TOOLS
        curl            CMAKE_REQUIRE_FIND_PACKAGE_CURL
        libarchive      CMAKE_REQUIRE_FIND_PACKAGE_LibArchive
    INVERTED_FEATURES
        curl            DISABLE_CURL
        libarchive      DISABLE_ARCHIVE
)

vcpkg_find_acquire_program(PKGCONFIG)

# Prevent upstream from replacing vcpkg's pkg-config paths with Homebrew paths.
unset(ENV{HOMEBREW_PREFIX})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_SYSTEM_ICU=True
        -DCMAKE_REQUIRE_FIND_PACKAGE_Leptonica=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenCL=ON
        -DLeptonica_DIR=YES
        -DLEPT_TIFF_RESULT=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_OpenCL
        CMAKE_REQUIRE_FIND_PACKAGE_CURL
        CMAKE_REQUIRE_FIND_PACKAGE_LibArchive
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tesseract)

set(config_dependencies "")
if("curl" IN_LIST FEATURES)
    string(APPEND config_dependencies "find_dependency(CURL)\n")
endif()
string(APPEND config_dependencies "find_dependency(Leptonica)\n")
if("libarchive" IN_LIST FEATURES)
    string(APPEND config_dependencies "find_dependency(LibArchive)\n")
endif()
string(APPEND config_dependencies [[
if(ANDROID)
    find_dependency(CpuFeaturesNdkCompat CONFIG)
endif()
]])
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tesseract/TesseractConfig.cmake"
    "find_dependency(Leptonica)"
    "${config_dependencies}"
)

vcpkg_copy_tools(TOOL_NAMES tesseract AUTO_CLEAN)
vcpkg_fixup_pkgconfig()

if("training-tools" IN_LIST FEATURES)
    list(APPEND TRAINING_TOOLS
        ambiguous_words classifier_tester combine_tessdata
        cntraining dawg2wordlist mftraining shapeclustering
        wordlist2dawg combine_lang_model lstmeval lstmtraining text2image
        set_unicharset_properties unicharset_extractor merge_unicharsets
        )
    vcpkg_copy_tools(TOOL_NAMES ${TRAINING_TOOLS} AUTO_CLEAN)
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install:
file(GLOB API_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/api/*.h")
file(INSTALL ${API_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/api")

file(GLOB ARCH_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/arch/*.h")
file(INSTALL ${ARCH_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/arch")

file(GLOB CCMAIN_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/ccmain/*.h")
file(INSTALL ${CCMAIN_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/ccmain")

file(GLOB CCSTRUCT_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/ccstruct/*.h")
file(INSTALL ${CCSTRUCT_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/ccstruct")

file(GLOB CCUTIL_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/ccutil/*.h")
file(INSTALL ${CCUTIL_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/ccutil")

file(GLOB CLASSIFY_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/classify/*.h")
file(INSTALL ${CLASSIFY_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/classify")

file(GLOB CUTIL_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/cutil/*.h")
file(INSTALL ${CUTIL_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/cutil")

file(GLOB DICT_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/dict/*.h")
file(INSTALL ${DICT_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/dict")

file(GLOB LSTM_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/lstm/*.h")
file(INSTALL ${LSTM_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/lstm")

file(GLOB TEXTORD_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/textord/*.h")
file(INSTALL ${TEXTORD_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/textord")

file(GLOB VIEWER_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/viewer/*.h")
file(INSTALL ${VIEWER_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/viewer")

file(GLOB WORDREC_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/wordrec/*.h")
file(INSTALL ${WORDREC_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tesseract/wordrec")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
