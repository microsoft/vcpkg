include(vcpkg_common_functions)

#the port uses inside the CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which is discouraged by vcpkg.
#Since it's its author choice, we should not disallow it, but unfortunately looks like it's broken, so we block it anyway...
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusmuja/flann
    REF  1d04523268c388dabf1c0865d69e1b638c8c7d9d
    SHA512 61e322222c2daa0b9677095e5ca231cba7c305ce754ad8e659eee350111c1e04351181c3af04e45ab6e5c9edea49c7b9ec6499bb0dbc080b87af36eb11c6ef7c
    HEAD_REF master
    PATCHES fix-build-error.patch
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
        -DCMAKE_DEBUG_POSTFIX=d
        -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flann/COPYING ${CURRENT_PACKAGES_DIR}/share/flann/copyright)
