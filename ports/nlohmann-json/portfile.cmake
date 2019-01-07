include(vcpkg_common_functions)

set(SOURCE_VERSION 3.5.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nlohmann-json-v${SOURCE_VERSION})

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}/single_include/lohmann-json/json.hpp"
    SHA512 6e8df9c0a8b5e74cc03f1c7620820215d43b642e213d30481830e5608c8196455dab5a5b604758c25dc6f45bd394fc0be6c8f8712a6498e96b3fd2e7d388d3c0
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}/LICENSE.MIT"
    SHA512 0fdb404547467f4523579acde53066badf458504d33edbb6e39df0ae145ed27d48a720189a60c225c0aab05f2aa4ce4050dcb241b56dc693f7ee9f54c8728a75
)

vcpkg_download_distfile(CMakeLists.txt
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/CMakeLists.txt"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}/CMakeLists.txt"
    SHA512  c763a16ff8026f049041e4461040416278d51751a6ac37ed1f4bfb565c748f2307e121fa6f71c2420d30ceb231cfb68b3f502cb8c3750371c1bf90e1f651578f
)

vcpkg_download_distfile(cmake/config.cmake.in
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/cmake/config.cmake.in"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}/cmake/config.cmake.in"
    SHA512  7caab6166baa891f77f5b632ac4a920e548610ec41777b885ec51fe68d3665ffe91984dd2881caf22298b5392dfbd84b526fda252467bb66de9eb90e6e6ade5a
)

vcpkg_download_distfile(nlohmann_json.natvis
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/nlohmann_json.natvis"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}/nlohmann_json.natvis"
    SHA512  9bce6758db0e54777394a4e718e60a281952b15f0c6dc6a6ad4a6d023c958b5515b2d39b7d4c66c03f0d3fdfdc1d6c23afb8b8419f1345c9d44d7b9a9ee2582b
)

file(
    COPY 
        ${DOWNLOADS}/nlohmann-json-v${SOURCE_VERSION}/LICENSE.MIT
        ${DOWNLOADS}/nlohmann-json-v${SOURCE_VERSION}/CMakeLists.txt
        ${DOWNLOADS}/nlohmann-json-v${SOURCE_VERSION}/nlohmann_json.natvis
    DESTINATION
        ${SOURCE_PATH}
)

file(
    COPY 
        ${DOWNLOADS}/nlohmann-json-v${SOURCE_VERSION}/single_include/lohmann-json/json.hpp
    DESTINATION
        ${SOURCE_PATH}/single_include/lohmann-json
)

file(
    COPY 
        ${DOWNLOADS}/nlohmann-json-v${SOURCE_VERSION}/cmake/config.cmake.in
    DESTINATION
        ${SOURCE_PATH}/cmake
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DJSON_BuildTests=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/debug
)
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
