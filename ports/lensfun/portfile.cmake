vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lensfun/lensfun
    REF "v${VERSION}"
    SHA512 4db9a08d51ba50c7c2ff528d380bb28e34698b2bb5c40e5f3deeaa5544c888ac7e0f638bbc3f33a4f75dbb67e0425ca36ce6d8cd1d8c043a4173a2df47de08c6
    HEAD_REF master
    PATCHES fix_build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LENSFUN_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LENSFUN_STATIC_CRT)

set(LENSFUN_EXTRA_OPTS "")
if("python" IN_LIST FEATURES)
    find_file(INITIAL_PYTHON3
        NAMES "python3${VCPKG_HOST_EXECUTABLE_SUFFIX}" "python${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/python3"
        NO_DEFAULT_PATH
        REQUIRED
    )
    x_vcpkg_get_python_packages(OUT_PYTHON_VAR PYTHON3
        PYTHON_EXECUTABLE "${INITIAL_PYTHON3}"
        PYTHON_VERSION "3"
        PACKAGES setuptools
    )
else()
    set(PYTHON3 "false")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND LENSFUN_EXTRA_OPTS -DPLATFORM_WINDOWS=ON)
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND LENSFUN_EXTRA_OPTS -DBUILD_FOR_SSE=OFF -DBUILD_FOR_SSE2=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${LENSFUN_EXTRA_OPTS}
        -DBUILD_STATIC=${LENSFUN_STATIC_LIB}
        -DBUILD_WITH_MSVC_STATIC_RUNTIME=${LENSFUN_STATIC_CRT}
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_LENSTOOL=OFF
        -DINSTALL_HELPER_SCRIPTS=OFF
        "-DPYTHON=${PYTHON3}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(READ "${SOURCE_PATH}/README.md" license_comment)
string(REGEX REPLACE "^.*\n(LICENSE\n)---+\n(.*)" "\\1\\2" license_comment "${license_comment}")
string(REGEX REPLACE "[^\n]+\n---+.*\$" "" license_comment "${license_comment}")
vcpkg_install_copyright(
    COMMENT "${license_comment}"
    FILE_LIST "${SOURCE_PATH}/docs/gpl-3.0.txt" "${SOURCE_PATH}/docs/lgpl-3.0.txt"
)
