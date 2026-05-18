if("x11" IN_LIST FEATURES)
    message(WARNING "${PORT} requires the following libraries from the system package manager:\n    libxmu-dev\n    libxi-dev\n    libgl-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxmu-dev libxi-dev libgl-dev.")
endif()

# Don't change to vcpkg_from_github! The sources in the git repository (archives) are missing some files that are distributed inside releases.
# More info: https://github.com/nigels-com/glew/issues/31 and https://github.com/nigels-com/glew/issues/13
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nigels-com/glew/releases/download/glew-${VERSION}/glew-${VERSION}.tgz"
    FILENAME "glew-${VERSION}.tgz"
    SHA512 cb4caecf32ec0f180c2691dc7769ffc99571c64f259a2663a2b80e788f1c2fd5362c59e0caaeefed6fb78a4070366d244666a657358049b09071b59fae2377e0
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE glew
    PATCHES
        fix-LNK2019.patch
        trim-build.diff
)

set(options "")
if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND options "-DGLEW_X11=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build/cmake"
    OPTIONS
        ${options}
        -DBUILD_UTILS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glew)
vcpkg_fixup_pkgconfig()

# Burn-in CMake build config
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/GL/glew.h" "ifndef GLEW_NO_GLU" "if 0")

if(NOT VCPKG_BUILD_TYPE)
    set(libname GLEW)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(libname glew32)
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glew.pc" " -l${libname}" " -l${libname}d")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/GL/glew.h" "#ifdef GLEW_STATIC" "#if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/GL/wglew.h" "#ifdef GLEW_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
