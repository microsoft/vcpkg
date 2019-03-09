include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-1.2.15
    SHA512 38b94a650ec205377ae1503d0ec8a5254ef6d50ed0acac8d985b57b64bc16ea042cfa41e19e5ef8317980c4afb83186829f5bc3da9433d0a649dfd10554801b5
    HEAD_REF master
    PATCHES export-symbols-only-in-shared-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/SDL1_2017.sln DESTINATION ${SOURCE_PATH}/VisualC/ )
file(COPY ${CMAKE_CURRENT_LIST_DIR}/SDL.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDL )
file(COPY ${CMAKE_CURRENT_LIST_DIR}/SDLmain.vcxproj DESTINATION ${SOURCE_PATH}/VisualC/SDLmain )

configure_file(${SOURCE_PATH}/include/SDL_config.h.default ${SOURCE_PATH}/include/SDL_config.h COPYONLY)

# This text file gets copied as a library, and included as one in the package 
file(REMOVE_RECURSE ${SOURCE_PATH}/src/hermes/COPYING.LIB)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH VisualC/SDL1_2017.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    ALLOW_ROOT_INCLUDES
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/doxyfile)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/SDLmain.lib)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDLmaind.lib)
endif()
