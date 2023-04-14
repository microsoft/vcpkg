set(program_name doxygen)
set(program_version 1.9.1)
vcpkg_list(SET sourceforge_args
    REPO doxygen
    REF "rel-${program_version}"
    FILENAME "doxygen-${program_version}.windows.bin.zip"
    SHA512 c3eeb6b9fa4eab70fb6b0864fbbf94fb8050f3fee38d117cf470921a80e3569cc1c8b0272604d6731e05f01790cfaa70e159bec5d0882fc4f2d8ae4a5d52a21b
    NO_REMOVE_ONE_LEVEL
    WORKING_DIRECTORY "${DOWNLOADS}/tools/doxygen"
    )
set(tool_subdirectory c3eeb6b9fa-76d69c6db5)
