include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusmuja/flann
    REF  1.9.1
    SHA512 0da78bb14111013318160dd3dee1f93eb6ed077b18439fd6496017b62a8a6070cc859cfb3e08dad4c614e48d9dc1da5f7c4a21726ee45896d360506da074a6f7
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-install-flann.patch
        ${CMAKE_CURRENT_LIST_DIR}/Revert-fix-install-flann.patch
        ${CMAKE_CURRENT_LIST_DIR}/export-all-symbols-of-flann-cpp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOC=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
        -DCMAKE_DEBUG_POSTFIX=-gd
        -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/flann.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann-gd.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/flann_cpp.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann_cpp-gd.lib)

    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/flann_s.lib ${CURRENT_PACKAGES_DIR}/lib/flann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/flann_s-gd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann-gd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/flann_cpp_s.lib ${CURRENT_PACKAGES_DIR}/lib/flann_cpp.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/flann_cpp_s-gd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann_cpp-gd.lib)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/flann_s.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann_s-gd.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/flann_cpp_s.lib ${CURRENT_PACKAGES_DIR}/debug/lib/flann_cpp_s-gd.lib)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flann/COPYING ${CURRENT_PACKAGES_DIR}/share/flann/copyright)
