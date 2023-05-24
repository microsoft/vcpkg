vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/nmslib
    REF v2.1.1
    SHA512 62BBB965EA4BF1D416ED78231B1BA4B41C0F46327D7BE16D1F98095DB63EF0E0D893B70040009711BC9C68555B1B8C4038F5032ABD66B759E955E2CBB0553EC3
    HEAD_REF master
)

# TODO: check SSE and AVX availability and set corresponding tags
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/similarity_search"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Move headers into separate folder
set(SUBFOLDERS factory method space)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/nmslib")
foreach(SUBFOLDER ${SUBFOLDERS})
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/nmslib/${SUBFOLDER}")
endforeach()

file(GLOB HEADERS "${CURRENT_PACKAGES_DIR}/include/*.h" "${CURRENT_PACKAGES_DIR}/include/*/*.h")
foreach(HEADER ${HEADERS})
    string(REPLACE "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include/nmslib" MOVED_HEADER "${HEADER}")
    file(RENAME "${HEADER}" "${MOVED_HEADER}")
endforeach(HEADER ${HEADERS})

foreach(SUBFOLDER ${SUBFOLDERS})
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${SUBFOLDER}/")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Put the license file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
