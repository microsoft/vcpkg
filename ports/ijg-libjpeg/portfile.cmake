if(EXISTS ${CURRENT_INSTALLED_DIR}/share/libturbo-jpeg/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'libturbo-jpeg'. Please remove libturbo-jpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
if(EXISTS ${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'mozjpeg'. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS        "http://www.ijg.org/files/jpegsr9d.zip"
    FILENAME    "jpegsr9d.zip"
    SHA512      441a783c945fd549693dbe3932d8d35e1ea00d8464870646760ed84a636facb4d7afe0ca3ab988e7281a71e41c2e96be618b8c6a898f116517e639720bba82a3
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# Replace some #define in jconfig.txt to #cmakedefine so the CMakeLists.txt can run `configure_file` command.
# See https://github.com/LuaDist/libjpeg
vcpkg_replace_string(${SOURCE_PATH}/jconfig.txt
    "#define HAVE_STDDEF_H"
    "#cmakedefine HAVE_STDDEF_H"
)
vcpkg_replace_string(${SOURCE_PATH}/jconfig.txt
    "#define HAVE_STDLIB_H"
    "#cmakedefine HAVE_STDLIB_H"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXECUTABLES=OFF # supports [tools] feature to enable this option?
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
