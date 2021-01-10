vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/jiixyj/libebur128/archive/v1.2.4.zip"
    FILENAME "v1.2.4.zip"
    SHA512 50469750120fa2c00185e53a00637eaca09d493edc5f532ab5bd227cdce87469f8ba7bde6dba2c5faabfadcc07096cc99222824762d82b132c0e343642a0eb31
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

set(LIBEBUR128_OPTIONS -DENABLE_INTERNAL_QUEUE_H=ON)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LIBEBUR128_OPTIONS ${LIBEBUR128_OPTIONS} -DBUILD_STATIC_LIBS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS ${LIBEBUR128_OPTIONS}
)

vcpkg_install_cmake()

# Remove duplicated header files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Remove dynmatic libraries on static builds
    file(GLOB DLL_PATHS "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    foreach(DLL_PATH ${DLL_PATHS})
        file(REMOVE "${DLL_PATH}")
    endforeach()
else()
    # Move DLLs from lib/ to bin/ (already fixed upstream on latest master)
    file(GLOB DLL_PATHS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    foreach(DLL_PATH ${DLL_PATHS})
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/")
        get_filename_component(DLL_FILENAME "${DLL_PATH}" NAME)
        file(RENAME "${DLL_PATH}" "${CURRENT_PACKAGES_DIR}/bin/${DLL_FILENAME}")
    endforeach()

    file(GLOB DLL_PATHS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    foreach(DLL_PATH ${DLL_PATHS})
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/")
        get_filename_component(DLL_FILENAME "${DLL_PATH}" NAME)
        file(RENAME "${DLL_PATH}" "${CURRENT_PACKAGES_DIR}/debug/bin/${DLL_FILENAME}")
    endforeach()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libebur128 RENAME copyright)
