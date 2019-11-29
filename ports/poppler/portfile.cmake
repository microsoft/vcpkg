include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO poppler/poppler
    REF poppler-0.82.0
    SHA512 3d0c8ce6cb4eec5b9039583209d61f7db9cf9f12121d7e9354853ddf3680f885839023fa2b024649c87289c1c473067eb077ed800e60c72f9b8afbb7d1395ca2
    HEAD_REF master
    PATCHES fix-cmake.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindCairo.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindFontconfig.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindGLIB.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindGObjectIntrospection.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindGTK.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindIconv.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindLCMS2.cmake)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/poppler-config.cmake.in DESTINATION ${SOURCE_PATH})

set(ENABLE_LIBCURL OFF)
if("curl" IN_LIST FEATURES)
    set(ENABLE_LIBCURL ON)
endif()

set(ENABLE_UTILS OFF)
if("utils" IN_LIST FEATURES)
  set(ENABLE_UTILS ON)
endif()

set(ENABLE_CPP OFF)
set(BUILD_CPP_TESTS OFF)
if("cpp" IN_LIST FEATURES)
    set(ENABLE_CPP ON)
    if ("tests" IN_LIST FEATURES)
        set(BUILD_CPP_TESTS ON)
    endif()
endif()

set(ENABLE_QT5 OFF)
set(BUILD_QT5_TESTS OFF)
if("qt5" IN_LIST FEATURES)
    set(ENABLE_QT5 ON)
    if ("tests" IN_LIST FEATURES)
        set(BUILD_QT5_TESTS ON)
    endif()
endif()

set(ENABLE_GLIB OFF)
set(BUILD_GTK_TESTS OFF)
if("glib" IN_LIST FEATURES)
    set(ENABLE_GLIB ON)
    
    vcpkg_find_acquire_program(PERL) # find_program(GLIB2_MKENUMS glib-mkenums) in glib/CMakeLitsts.txt
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")
    if ("tests" IN_LIST FEATURES)
        set(BUILD_GTK_TESTS ON)
    endif()
endif()

set(PKG_CONFIG_SUFFIX "")
if (WIN32)
    set(PKG_CONFIG_SUFFIX ".bat")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DENABLE_LIBCURL=${ENABLE_LIBCURL}
        -DENABLE_UTILS=${ENABLE_UTILS}
        -DENABLE_CPP=${ENABLE_CPP}
        -DBUILD_CPP_TESTS=${BUILD_CPP_TESTS}
        -DENABLE_QT5=${ENABLE_QT5}
        -DBUILD_QT5_TESTS=${BUILD_QT5_TESTS}
        -DENABLE_GLIB=${ENABLE_QT5}
        -DBUILD_GTK_TESTS=${BUILD_GTK_TESTS}
        -DPKG_CONFIG_SUFFIX=${PKG_CONFIG_SUFFIX}
        -DPERL_EXE_DIR=${PERL_EXE_PATH}
        -DENABLE_NSS3=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/poppler)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler RENAME copyright-xpdf)
file(INSTALL ${SOURCE_PATH}/AUTHORS DESTINATION ${CURRENT_PACKAGES_DIR}/share/poppler)

