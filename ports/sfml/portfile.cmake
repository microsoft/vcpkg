
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SFML-2.4.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.sfml-dev.org/files/SFML-2.4.2-sources.zip"
    FILENAME "SFML-2.4.2-sources.zip"
    SHA512 14f2b9f244bbff681d1992581f20012f3073456e4baed0fb2bf2cf82538e9c5ddd8ce01b0cfb3874af47091ec19654aa23c426df04fe1ffcfa209623dc362f85)

vcpkg_extract_source_archive(${ARCHIVE})

file(REMOVE_RECURSE ${SOURCE_PATH}/extlibs)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
        OPTIONS_DEBUG
            -DSFML_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# don't force users to define SFML_STATIC while using static library
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/SFML/Config.hpp "#undef SFML_API_IMPORT\n#define SFML_API_IMPORT\n")
endif()

# move sfml-main to manual link dir
file(COPY ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/sfml-main.lib)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/sfml-main-d.lib)

file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sfml/license.txt ${CURRENT_PACKAGES_DIR}/share/sfml/copyright)
