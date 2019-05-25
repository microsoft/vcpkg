include(vcpkg_common_functions)

#the port uses inside the CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS, which is discouraged by vcpkg.
#Since it's its author choice, we should not disallow it, but unfortunately looks like it's broken, so we block it anyway...
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusmuja/flann
    REF 06a49513138009d19a1f4e0ace67fbff13270c69
    SHA512 0da78bb14111013318160dd3dee1f93eb6ed077b18439fd6496017b62a8a6070cc859cfb3e08dad4c614e48d9dc1da5f7c4a21726ee45896d360506da074a6f7
    HEAD_REF master
    PATCHES
        fix_targets.patch
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
