include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "nmslib only supports static linkage. Building statically.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO searchivarius/nmslib
    REF v1.7.2
    SHA512 2f910f752bfb1146aa8d1765fd5faf64d718a92ab7edf9d8ac0a2d9c4359d42b07b3cd553e2aff93da8b009add52ab9cce6b841f5175f57163f73f643ff62c19
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
