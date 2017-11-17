include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freeglut-3.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/freeglut/freeglut/3.0.0/freeglut-3.0.0.tar.gz"
    FILENAME "freeglut-3.0.0.tar.gz"
    SHA512 9c45d5b203b26a7ff92331b3e080a48e806c92fbbe7c65d9262dd18c39cd6efdad8a795a80f499a2d23df84b4909dbd7c1bab20d7dd3555d3d88782ce9dd15b0
)
vcpkg_extract_source_archive(${ARCHIVE})

# disable debug suffix, because FindGLUT.cmake from CMake 3.8 doesn't support it
file(READ ${SOURCE_PATH}/CMakeLists.txt FREEGLUT_CMAKELISTS)
string(REPLACE "SET( CMAKE_DEBUG_POSTFIX \"d\" )"
               "\#SET( CMAKE_DEBUG_POSTFIX \"d\" )" FREEGLUT_CMAKELISTS "${FREEGLUT_CMAKELISTS}")
file(WRITE ${SOURCE_PATH}/CMakeLists.txt "${FREEGLUT_CMAKELISTS}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(FREEGLUT_STATIC OFF)
    set(FREEGLUT_DYNAMIC ON)
else()
    set(FREEGLUT_STATIC ON)
    set(FREEGLUT_DYNAMIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFREEGLUT_BUILD_STATIC_LIBS=${FREEGLUT_STATIC}
        -DFREEGLUT_BUILD_SHARED_LIBS=${FREEGLUT_DYNAMIC}
        -DFREEGLUT_BUILD_DEMOS=OFF
        -DINSTALL_PDB=OFF # Installing pdbs failed on debug static. So, disable it and let vcpkg_copy_pdbs() do it
)

vcpkg_install_cmake()

# Patch header
file(READ ${CURRENT_PACKAGES_DIR}/include/GL/freeglut_std.h FREEGLUT_STDH)
string(REPLACE "pragma comment (lib, \"freeglut_staticd.lib\")"
               "pragma comment (lib, \"freeglut.lib\")" FREEGLUT_STDH "${FREEGLUT_STDH}")
string(REPLACE "pragma comment (lib, \"freeglutd.lib\")"
               "pragma comment (lib, \"freeglut.lib\")" FREEGLUT_STDH "${FREEGLUT_STDH}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/GL/freeglut_std.h "${FREEGLUT_STDH}")

# Rename static lib (otherwise it's incompatible with FindGLUT.cmake)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/freeglut_static.lib ${CURRENT_PACKAGES_DIR}/lib/freeglut.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/freeglut_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/freeglut.lib)
endif()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freeglut)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freeglut/COPYING ${CURRENT_PACKAGES_DIR}/share/freeglut/copyright)

vcpkg_copy_pdbs()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
