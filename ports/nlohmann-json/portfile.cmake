set(SOURCE_VERSION 3.8.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT}-v${SOURCE_VERSION})

file(MAKE_DIRECTORY ${SOURCE_PATH})

function(download_src SUBPATH SHA512)
    vcpkg_download_distfile(FILE
        URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/${SUBPATH}"
        FILENAME "${PORT}-v${SOURCE_VERSION}/${SUBPATH}"
        SHA512 ${SHA512}
    )
    get_filename_component(SUBPATH_DIR "${SOURCE_PATH}/${SUBPATH}" DIRECTORY)
    file(COPY ${FILE} DESTINATION ${SUBPATH_DIR})
endfunction()

download_src(CMakeLists.txt 18151b19cb5258e58feffac8d4aed559c87e158dc217f47be23351b15c86e1d3f3c5ad2f7d11beabe3f0c0f948f3da1b9a807d425b1a9a0bb1ed74767cefafa9)
download_src(LICENSE.MIT d5f7bb6a33469e19250a5e20db44e7ba09602ee85bc0afb03e4932402b08ca1c0dbbe6376b7e0a84eb11c782d70ae96f130755967204d35420c6ecbcafd301e5)
download_src(nlohmann_json.natvis 9bce6758db0e54777394a4e718e60a281952b15f0c6dc6a6ad4a6d023c958b5515b2d39b7d4c66c03f0d3fdfdc1d6c23afb8b8419f1345c9d44d7b9a9ee2582b)
download_src(cmake/config.cmake.in 7caab6166baa891f77f5b632ac4a920e548610ec41777b885ec51fe68d3665ffe91984dd2881caf22298b5392dfbd84b526fda252467bb66de9eb90e6e6ade5a)
download_src(cmake/nlohmann_jsonConfigVersion.cmake.in 3b3ca2cfe740ba9646e5976b1112ba37c229bf527959bfb47a5e6c2fcd5ba6b5626d3c2455c181fe41a72ec78500738e2950e4fe76a2e91ba2073ba01f5595a8)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/include.zip"
    FILENAME ${PORT}-v${SOURCE_VERSION}-include.zip
    SHA512 f4453aced8d74cf7c65d038fdf8da1e2b2153a1c15e26c7f25394ab1ce81f78920dd30b418b1db4cbf3f934df0459024230700bdd943aad569b2525b6a26e5d0
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH OUT_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SOURCE_VERSION}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    NO_REMOVE_ONE_LEVEL
)
file(COPY "${OUT_PATH}/include" DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DJSON_BuildTests=0 
        -DJSON_MultipleHeaders=ON
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
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
