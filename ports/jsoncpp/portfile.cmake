include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/jsoncpp-1.7.7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/open-source-parsers/jsoncpp/archive/1.7.7.zip"
    FILENAME "jsoncpp-1.7.7.zip"
    SHA512 3801faab0b1982bc41dac3049e0f7d24ea3dc759b77afc1ca7365b95a36460f87a74a0f5c6efd4c4a315ea2ca904b38f454b0a70133cda339c4a01ae8049cecb
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(JSONCPP_STATIC OFF)
    set(JSONCPP_DYNAMIC ON)
else()
    set(JSONCPP_STATIC ON)
    set(JSONCPP_DYNAMIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DJSONCPP_WITH_CMAKE_PACKAGE:BOOL=ON
            -DBUILD_STATIC_LIBS:BOOL=${JSONCPP_STATIC}
            -DBUILD_SHARED_LIBS:BOOL=${JSONCPP_DYNAMIC}
)

vcpkg_install_cmake()

# Fix CMake files
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/jsoncpp ${CURRENT_PACKAGES_DIR}/share/jsoncpp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(READ ${CURRENT_PACKAGES_DIR}/share/jsoncpp/jsoncppConfig.cmake _contents)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n\n" "\n" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/jsoncpp/jsoncppConfig.cmake ${_contents})

file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/jsoncpp/jsoncppConfig-debug.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/jsoncpp/jsoncppConfig-debug.cmake "${_contents}")

# Remove useless files in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncpp/copyright)

# Copy pdb files
vcpkg_copy_pdbs()
