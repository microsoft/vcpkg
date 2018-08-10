include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF v3.1.1
    SHA512 f6d8974e2f48bae7e96a8938df3ad5efc403036c1dcbe2b48edd276ee7923802ba3e95e3f3bd9db17985e427b8e4f78950df0cbba83ae99d508ed04633816c95
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/disable-platform-lib-dir.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DwxUSE_REGEX=builtin
        -DwxUSE_ZLIB=sys
        -DwxUSE_EXPAT=sys
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBPNG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxUSE_STL=ON
        -DwxBUILD_DISABLE_PLATFORM_LIB_DIR=ON
)

vcpkg_install_cmake()

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
if(DLLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    foreach(DLL ${DLLS})
        get_filename_component(N "${DLL}" NAME)
        file(RENAME ${DLL} ${CURRENT_PACKAGES_DIR}/bin/${N})
    endforeach()
endif()
file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DLLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    foreach(DLL ${DLLS})
        get_filename_component(N "${DLL}" NAME)
        file(RENAME ${DLL} ${CURRENT_PACKAGES_DIR}/debug/bin/${N})
    endforeach()
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/docs/licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxwidgets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wxwidgets/licence.txt ${CURRENT_PACKAGES_DIR}/share/wxwidgets/copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
