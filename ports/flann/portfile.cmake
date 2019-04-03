include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusmuja/flann
    REF  1.9.1
    SHA512 0da78bb14111013318160dd3dee1f93eb6ed077b18439fd6496017b62a8a6070cc859cfb3e08dad4c614e48d9dc1da5f7c4a21726ee45896d360506da074a6f7
    HEAD_REF master
    PATCHES
        export-all-symbols-of-flann-cpp.patch
        no-write-src-dir.patch
        flann-linux.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
        -DCMAKE_DEBUG_POSTFIX=-gd
        -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(LIB_PREFIX "")
    set(LIB_SUFFIX ".lib")
else()
    set(LIB_PREFIX "lib")
    set(LIB_SUFFIX ".a")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann-gd${LIB_SUFFIX})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_cpp${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_cpp-gd${LIB_SUFFIX})

    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_s${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann${LIB_SUFFIX})
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_s-gd${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann-gd${LIB_SUFFIX})
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_cpp_s${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_cpp${LIB_SUFFIX})
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_cpp_s-gd${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_cpp-gd${LIB_SUFFIX})
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_s${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_s-gd${LIB_SUFFIX})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/${LIB_PREFIX}flann_cpp_s${LIB_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_PREFIX}flann_cpp_s-gd${LIB_SUFFIX})
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flann/COPYING ${CURRENT_PACKAGES_DIR}/share/flann/copyright)
