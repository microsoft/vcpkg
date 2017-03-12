
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pango-1.40.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-1.40.3.tar.xz"
    FILENAME "pango-1.40.3.tar.xz"
    SHA512 ff82395e8487624dffe212975b72b3383dcebb197a8675c8b409665e3e2e30fc23d9a6c25c3129a115adb7182b2a71a49550dbe881eb7ee9bbc572de6ba18d27)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS_DEBUG
	    -DPANGO_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pango)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pango/COPYING ${CURRENT_PACKAGES_DIR}/share/pango/copyright)
