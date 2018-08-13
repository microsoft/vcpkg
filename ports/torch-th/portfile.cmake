if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic linkage")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic crt")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO torch/torch7
    REF fd0ee3bbf7bfdd21ab10c5ee70b74afaef9409e1
    SHA512 3a7a006ec624f25216e2b433380ccaf04710fd452f28ce853d3018e4ced6b6e066e61ff9165b8c0526825748a335c976cfb7accff4d1a16ae1be0db94b2c8a22
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/debug.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lib/TH
    PREFER_NINJA
    OPTIONS
        -DWITH_OPENMP=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/torch-th RENAME copyright)
