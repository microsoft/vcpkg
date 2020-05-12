include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/nmslib
    REF c9fc0b862f09260b558cf81e94e0d58aca15d9e9
    SHA512 ac9c79e3ac991dd58f239f7e0b2bd6c3185907aa283bc42098aadddac87b361867f002664cc14853822f92a491d95269578bea01aa00477e39a40424320000a1
    HEAD_REF master
    PATCHES
        fix-headers.patch
        fix-cmake-order.patch
)

set(WITH_EXTRAS OFF)
if("extra" IN_LIST FEATURES)
    set(WITH_EXTRAS ON)
endif()

# TODO: check SSE and AVX avability and set corresponding tags
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/similarity_search
    PREFER_NINJA
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
