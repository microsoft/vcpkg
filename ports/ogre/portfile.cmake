
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sinbad-ogre-06631aef218d)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sinbad/ogre/get/06631aef218d.tar.bz2"
    FILENAME "ogre-2.1-06631aef218d.tar.bz2"
    SHA512 43e2040e0ad8e7729d66b7d1a52d880987f158d4b295ad646debec98da36d2892eb985b515f749a82408a38a5169fe05dd9e98162e75379a33812fb8abca1c2b)    

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/dont-assume-static-freeimage.patch")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC_LIB ON)
else()
    set(OGRE_STATIC_LIB OFF)
endif()
if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(OGRE_STATIC_CRT ON)
else()
    set(OGRE_STATIC_CRT OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOGRE_STATIC=${OGRE_STATIC_LIB}
        -DOGRE_CONFIG_STATIC_LINK_CRT=${OGRE_STATIC_CRT}
        -DOGRE_INSTALL_DOCS=OFF
        -DOGRE_USE_BOOST=OFF
        -DOGRE_BUILD_MSVC_MP=OFF
        -DOGRE_BUILD_TOOLS=OFF) # tools are not supported in Windows Store and also are broken in static builds

vcpkg_install_cmake()

# place libraries in lib/
file(GLOB RELEASE_LIBS ${CURRENT_PACKAGES_DIR}/lib/Release/*.lib ${CURRENT_PACKAGES_DIR}/lib/Release/opt/*.lib)
file(GLOB DEBUG_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/Debug/*.lib ${CURRENT_PACKAGES_DIR}/debug/lib/Debug/opt/*.lib)
file(COPY ${RELEASE_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# place dlls in bin/
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB RELEASE_DLLS ${CURRENT_PACKAGES_DIR}/bin/Release/*.dll)
    file(GLOB DEBUG_DLLS ${CURRENT_PACKAGES_DIR}/debug/bin/Debug/*.dll)
    file(COPY ${RELEASE_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    vcpkg_copy_pdbs()
endif()

# place materials, shaders and stuff in tools/
file(COPY ${CURRENT_PACKAGES_DIR}/media DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ogre)

# cleanup
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/Release)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/Debug)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/Release)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/Debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/CMake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/media)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/media)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ogre/COPYING ${CURRENT_PACKAGES_DIR}/share/ogre/copyright)
