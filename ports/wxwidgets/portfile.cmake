include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF v3.1.3
    SHA512 4ecb5c2d13f9bda7aa3c12e887c351a0004509ec24bdd440542bec67e1b6dca20e7838a01236a71dd3cf2e1ba0653c40878047f406464cb2c9ee07c26d6f2599
    HEAD_REF master
    PATCHES disable-platform-lib-dir.patch fix-macos-clipboard.patch
)

set(OPTIONS)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(OPTIONS -DCOTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES=9999)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    set(OPTIONS
        -DwxUSE_OPENGL=OFF
        -DwxUSE_STACKWALKER=OFF
    )
endif()

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
        ${OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

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

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h ${CURRENT_PACKAGES_DIR}/include/wx/setup.h)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/mswu)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/mswud)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/msvc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
