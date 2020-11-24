
if(EXISTS ${CURRENT_INSTALLED_DIR}/share/libturbo-jpeg/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'libturbo-jpeg'. Please remove libturbo-jpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
if(EXISTS ${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright)
    message(FATAL_ERROR "'${PORT}' conflicts with 'mozjpeg'. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # the release doesn't have `__declspec(dllexport)`.
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

if(VCPKG_TARGET_IS_LINUX)
    # The deflated files are using CRLF. change them to LF before generating jconfig.h
    find_program(DOS2UNIX dos2unix REQUIRED)
    message(STATUS "Using dos2unix: ${DOS2UNIX}")

    vcpkg_execute_required_process(
        COMMAND ${DOS2UNIX} --force -n configure configure
        WORKING_DIRECTORY "${SOURCE_PATH}"
    )
    vcpkg_execute_required_process(
        COMMAND ${DOS2UNIX} -n config.sub config.sub
        WORKING_DIRECTORY "${SOURCE_PATH}"
    )
    vcpkg_execute_required_process(
        COMMAND ${DOS2UNIX} -n config.guess config.guess
        WORKING_DIRECTORY "${SOURCE_PATH}"
    )

    # Allow execution for 'configure' and generate jconfig.h
    vcpkg_execute_required_process(
        COMMAND chmod +x configure config.sub config.guess
        WORKING_DIRECTORY "${SOURCE_PATH}"
    )
    vcpkg_execute_required_process(
        COMMAND bash configure
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "pre-config-${TARGET_TRIPLET}"
    )
else()
    file(RENAME ${SOURCE_PATH}/jconfig.txt ${SOURCE_PATH}/jconfig.h)
endif()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

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
