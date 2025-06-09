if(EXISTS ${CURRENT_INSTALLED_DIR}/share/libjpeg-turbo/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'libturbo-jpeg'. Please remove libturbo-jpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
if(EXISTS ${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'mozjpeg'. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS        "http://www.ijg.org/files/jpegsr${VERSION}.zip"
    FILENAME    "jpegsr${VERSION}.zip"
    SHA512      f43e7cab21fb60d41c7a6842f5859ebeac34267f985870d999cc2e7e9e90ee552d667f054c0f162ef5e5ebaab87e285631432a7ca8441ba9837c4caa4fdf51ac
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# Replace some #define in jconfig.txt to #cmakedefine so the CMakeLists.txt can run `configure_file` command.
# See https://github.com/LuaDist/libjpeg
vcpkg_replace_string("${SOURCE_PATH}/jconfig.txt"
    "#define HAVE_STDDEF_H"
    "#cmakedefine HAVE_STDDEF_H"
)
vcpkg_replace_string("${SOURCE_PATH}/jconfig.txt"
    "#define HAVE_STDLIB_H"
    "#cmakedefine HAVE_STDLIB_H"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXECUTABLES=OFF # supports [tools] feature to enable this option?
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# There is no LICENSE file, but README containes some legal text.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
