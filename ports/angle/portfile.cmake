if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "Building with a gcc version less than 6.1 is not supported.")
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libx11-dev\n    libmesa-dev\n    libxi-dev\n    libxext-dev\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libmesa-dev libxi-dev libxext-dev.")
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ANGLE_CPU_BITNESS ANGLE_IS_64_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(ANGLE_CPU_BITNESS ANGLE_IS_32_BIT_CPU)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(ANGLE_CPU_BITNESS ANGLE_IS_64_BIT_CPU)
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

# chromium/4758
set(ANGLE_COMMIT b790affce32eda9b73883f1fdd35ab378e635a16)
set(ANGLE_VERSION 4758)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF ${ANGLE_COMMIT}
    SHA512 51ed88ae975c6f2e73fe8a09b1aea7ecee160bbef671db4662dc11b888a3fc9400a8959fdf2db727b5a6532915a6ea27079aa8456b0d8ed04dc0b4e2c8cf39cd
    # On update check headers against opengl-registry
    PATCHES
        001-fix-uwp.patch
        002-fix-builder-error.patch
        003-fix-mingw.patch
)

# Generate angle_commit.h
set(ANGLE_COMMIT_HASH_SIZE 12)
string(SUBSTRING "${ANGLE_COMMIT}" 0 ${ANGLE_COMMIT_HASH_SIZE} ANGLE_COMMIT_HASH)
set(ANGLE_COMMIT_DATE "invalid-date")
set(ANGLE_REVISION "${ANGLE_VERSION}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/angle_commit.h.in" "${SOURCE_PATH}/angle_commit.h" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/angle_commit.h.in" "${SOURCE_PATH}/src/common/angle_commit.h" @ONLY)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

function(checkout_in_path PATH URL REF)
    if(EXISTS "${PATH}")
        return()
    endif()
    
    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

checkout_in_path(
    "${SOURCE_PATH}/third_party/zlib"
    "https://chromium.googlesource.com/chromium/src/third_party/zlib"
    "efd9399ae01364926be2a38946127fdf463480db"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
    OPTIONS
        -D${ANGLE_CPU_BITNESS}=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-angle TARGET_PATH share/unofficial-angle)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# File conflict with opengl-registry! Make sure headers are similar on Update!
# angle defines some additional entrypoints. 
# opengl-registry probably needs an upstream update to account for those
# Due to that all angle headers get moved to include/angle. 
# If you want to use those instead of the onces provided by opengl-registry make sure 
# VCPKG_INSTALLED_DIR/include/angle is before VCPKG_INSTALLED_DIR/include
file(GLOB_RECURSE angle_includes "${CURRENT_PACKAGES_DIR}/include")
file(COPY ${angle_includes} DESTINATION "${CURRENT_PACKAGES_DIR}/include/angle")

set(_double_files
    include/GLES/egl.h
    include/GLES/gl.h
    include/GLES/glext.h
    include/GLES/glplatform.h
    include/GLES2/gl2.h
    include/GLES2/gl2ext.h
    include/GLES2/gl2platform.h
    include/GLES3/gl3.h
    include/GLES3/gl31.h
    include/GLES3/gl32.h
    include/GLES3/gl3platform.h)
foreach(_file ${_double_files})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${_file}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/${_file}")
    endif()
endforeach()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/GLES/"
    "${CURRENT_PACKAGES_DIR}/include/GLES3/"
)

