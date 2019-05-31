include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/nmslib
    REF 1eda05dccd5ed34df50a243dfc64c5e9187388f8
    SHA512 e4518c8dd84867bd0ac5dbc5d3b57d8053d1f73588fc0cf1d7c91cc4819f22dc7888d6be587691ebc1fd12b67de16de63b5e0a24847b6f7b49b57d1e6b457ebd
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-headers.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmake-order.patch
)

set(WITH_EXTRAS OFF)
if("extra" IN_LIST FEATURES)
    set(WITH_EXTRAS ON)
endif()

# TODO: check SSE and AVX avability and set corresponding tags
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/similarity_search
    OPTIONS
        -DWITH_EXTRAS=${WITH_EXTRAS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Move headers into separate folder
set(SUBFOLDERS factory method space)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/nmslib)
foreach(SUBFOLER ${SUBFOLDERS})
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/nmslib/${SUBFOLER})
endforeach()

file(GLOB HEADERS ${CURRENT_PACKAGES_DIR}/include/*.h ${CURRENT_PACKAGES_DIR}/include/*/*.h)
foreach(HEADER ${HEADERS})
    string(REPLACE "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include/nmslib"
                   MOVED_HEADER ${HEADER})
    file(RENAME ${HEADER} ${MOVED_HEADER})
endforeach(HEADER ${HEADERS})

foreach(SUBFOLER ${SUBFOLDERS})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/${SUBFOLER}/)
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nmslib/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nmslib/README.md ${CURRENT_PACKAGES_DIR}/share/nmslib/copyright)
