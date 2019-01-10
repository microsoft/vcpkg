include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF 112d3bd0aaacad51305e1464d4b381dabad0e88b
    SHA512 df20e072a5e024ca2b8fc0e2890bb8968c0c948a833149a6026d2eaf6ab57b88b6d00d0bfb3b8bfcf879c7875e7cfacb8c6bf454bfc083b41d76132c567ff7ae
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
