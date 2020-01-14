vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesseract-ocr/tesseract
    REF 4.1.0
    SHA512 d617f5c5b826640b2871dbe3d7973bcc5e66fafd837921a20e009d683806ed50f0f258aa455019d99fc54f5cb65c2fa0380e3a3c92b39ab0684b8799c730b09d
    PATCHES
        fix-tiff-linkage.patch
        fix-text2image.patch
)

# The built-in cmake FindICU is better
file(REMOVE ${SOURCE_PATH}/cmake/FindICU.cmake)

# Handle Static Library Output
if(VCPKG_LIBRARY_LINKAGE EQUAL "static")
    list(APPEND OPTIONS_LIST -DSTATIC=ON)
endif()

# Handle CONTROL
if("training_tools" IN_LIST FEATURES)
    list(APPEND OPTIONS_LIST -DBUILD_TRAINING_TOOLS=ON)
else()
    list(APPEND OPTIONS_LIST -DBUILD_TRAINING_TOOLS=OFF)
endif()
if("cpu_independed" IN_LIST FEATURES)
    list(APPEND OPTIONS_LIST -DTARGET_ARCHITECTURE=none)
else()
    list(APPEND OPTIONS_LIST -DTARGET_ARCHITECTURE=auto)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC=ON
        -DUSE_SYSTEM_ICU=True
        -DCMAKE_DISABLE_FIND_PACKAGE_LibArchive=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenCL=ON
        -DLeptonica_DIR=YES
        ${OPTIONS_LIST}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

# Install tool
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/tesseract)
set(EXTENSION)
if(WIN32)
    set(EXTENSION ".exe")
endif()

# copy training tools
set(TRAINING_TOOLS_DIR ${CURRENT_PACKAGES_DIR}/tools/tesseract/training)
if("training_tools" IN_LIST FEATURES)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/ambiguous_words${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/classifier_tester${EXTENSION} 	DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/combine_tessdata${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/cntraining${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/dawg2wordlist${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/mftraining${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/shapeclustering${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/wordlist2dawg${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/combine_lang_model${EXTENSION} 	DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/lstmeval${EXTENSION} 			DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/lstmtraining${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/set_unicharset_properties${EXTENSION} DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/unicharset_extractor${EXTENSION} 	DESTINATION ${TRAINING_TOOLS_DIR})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/text2image${EXTENSION} 		DESTINATION ${TRAINING_TOOLS_DIR})
endif()

file(COPY ${CURRENT_PACKAGES_DIR}/bin/tesseract${EXTENSION} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tesseract)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/tesseract)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)