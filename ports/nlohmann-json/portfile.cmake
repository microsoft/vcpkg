include(vcpkg_common_functions)

set(SOURCE_VERSION 3.7.0)
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

download_src(CMakeLists.txt f397536b06a2adaf717067f6bcbc4b23836d28bb7471143848259ef90f84bb5aadbd21bb387f80603fca791c9806b846e110e97a10de5b276f03a7fe6a97f2eb)
download_src(LICENSE.MIT 44e6d9510dd66195211aa8ce3e6eef55be524e82c5864f3bfb85f2ac1215529c8ca370c8746de61ad5739e5af1633a5985085dacd1ffe220cd21d06433936801)
download_src(nlohmann_json.natvis 9bce6758db0e54777394a4e718e60a281952b15f0c6dc6a6ad4a6d023c958b5515b2d39b7d4c66c03f0d3fdfdc1d6c23afb8b8419f1345c9d44d7b9a9ee2582b)
download_src(cmake/config.cmake.in 7caab6166baa891f77f5b632ac4a920e548610ec41777b885ec51fe68d3665ffe91984dd2881caf22298b5392dfbd84b526fda252467bb66de9eb90e6e6ade5a)
download_src(single_include/nlohmann/json.hpp 1a12ea9e54a19e398a4d7aa3be1759ce3666a1b479bd553fe11bc63897a8055f11f42871eee6c801756dde038d860c48043cc50df753835c9a9691a1876a159e)

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
