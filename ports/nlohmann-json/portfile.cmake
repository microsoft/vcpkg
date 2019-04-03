include(vcpkg_common_functions)

set(SOURCE_VERSION 3.6.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nlohmann-json-v${SOURCE_VERSION})

file(MAKE_DIRECTORY ${SOURCE_PATH})

function(download_src SUBPATH SHA512)
    vcpkg_download_distfile(FILE
        URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/${SUBPATH}"
        FILENAME "nlohmann-json-v${SOURCE_VERSION}/${SUBPATH}"
        SHA512 ${SHA512}
    )
    get_filename_component(SUBPATH_DIR "${SOURCE_PATH}/${SUBPATH}" DIRECTORY)
    file(COPY ${FILE} DESTINATION ${SUBPATH_DIR})
endfunction()

download_src(CMakeLists.txt ea5775c8eca3f387d152e6adadeb5e5454b7bce2bb45b305019248def2714b85b959196cb97f25b175ebebd044f179bcffa5ec62b0373bee3a8ca135f2988054)
download_src(LICENSE.MIT 44e6d9510dd66195211aa8ce3e6eef55be524e82c5864f3bfb85f2ac1215529c8ca370c8746de61ad5739e5af1633a5985085dacd1ffe220cd21d06433936801)
download_src(nlohmann_json.natvis 9bce6758db0e54777394a4e718e60a281952b15f0c6dc6a6ad4a6d023c958b5515b2d39b7d4c66c03f0d3fdfdc1d6c23afb8b8419f1345c9d44d7b9a9ee2582b)
download_src(cmake/config.cmake.in 7caab6166baa891f77f5b632ac4a920e548610ec41777b885ec51fe68d3665ffe91984dd2881caf22298b5392dfbd84b526fda252467bb66de9eb90e6e6ade5a)
download_src(single_include/nlohmann/json.hpp 17ad2911f054235002e273a34087f91122586de475792e9a41b8fa5cd0df3341867a976d702e2bb99459583d393afaabb481823700260bc19fb64eae544fc0bd)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DJSON_BuildTests=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nlohmann_json TARGET_PATH share/nlohmann_json)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_jsonTargets.cmake
    "{_IMPORT_PREFIX}/nlohmann_json.natvis"
    "{_IMPORT_PREFIX}/share/nlohmann_json/nlohmann_json.natvis"
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

if(EXISTS ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis
        ${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_json.natvis
    )
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)
