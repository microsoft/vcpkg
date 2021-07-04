vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/nmslib
    REF 5482e077d1c8637499f86231bcd3979cb7fa6aef # v2.0.6
    SHA512 e529c8d1d97e972f8314be9837e10f4ebab57d4a5f19a66341bb8e163dfe53d1d640a3909a708b021a52d0e6c2537954d749cb80e71757469700a3e9e173ceca
    HEAD_REF master
    PATCHES
        fix-headers.patch
)

# TODO: check SSE and AVX avability and set corresponding tags
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/similarity_search
    PREFER_NINJA
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
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
