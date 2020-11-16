
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS        "http://www.ijg.org/files/jpegsr9d.zip"
    FILENAME    "jpegsr9d.zip"
    SHA512      441a783c945fd549693dbe3932d8d35e1ea00d8464870646760ed84a636facb4d7afe0ca3ab988e7281a71e41c2e96be618b8c6a898f116517e639720bba82a3
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
# todo: jconfig.h should be genrated when `configure` is available
file(RENAME ${SOURCE_PATH}/jconfig.txt ${SOURCE_PATH}/jconfig.h)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXECUTABLES=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

# There is no LICENSE file, but README containes some legal text.
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
