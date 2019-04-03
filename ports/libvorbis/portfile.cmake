include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF 9eadeccdc4247127d91ac70555074239f5ce3529
    SHA512 26d6826eba57fd47ebf426ba5a0c961c87ff62e2bb4185190e4985de9ac49aa493f77a1bd01d3d0757eb89a8494ba7de3a506f76bf5c8942ac1de3f75746a301
    HEAD_REF master
    PATCHES
        0001-Dont-export-vorbisenc-functions.patch
        0002-Allow-deprecated-functions.patch
)

file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" OGG_INCLUDE)
foreach(LIBNAME ogg.lib libogg.a libogg.dylib libogg.so)
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/${LIBNAME}" OR EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/${LIBNAME}")
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/${LIBNAME}" OGG_LIB_REL)
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/${LIBNAME}" OGG_LIB_DBG)
        break()
    endif()
endforeach()

if(NOT OGG_LIB_REL)
    message(FATAL_ERROR "Could not find libraries for dependency libogg!")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DOGG_INCLUDE_DIRS=${OGG_INCLUDE}
    OPTIONS_RELEASE -DOGG_LIBRARIES=${OGG_LIB_REL}
    OPTIONS_DEBUG -DOGG_LIBRARIES=${OGG_LIB_DBG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/libvorbis/copyright COPYONLY)

vcpkg_copy_pdbs()
