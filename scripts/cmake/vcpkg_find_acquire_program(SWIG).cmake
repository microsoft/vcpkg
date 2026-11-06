set(program_version 4.3.1)
set(program_name swig)
if(CMAKE_HOST_WIN32)
    set(download_filename "swigwin-${program_version}.zip")
    set(download_sha512 "ca7210684b6ccb1b9bb186797bf1b67bbf3e76f6d0e702fee78edf7456992a4298eb5fa0b5f602a4240161fedd422920fe56e12cd60b8c8fd71c2f784f3d0f43")
    vcpkg_list(SET sourceforge_args
        REPO swig/swigwin
        REF "swigwin-${program_version}"
    )
    set(paths_to_search "${DOWNLOADS}/tools/swig/swigwin-${program_version}")
else()
    set(apt_package_name "swig")
    set(brew_package_name "swig")
endif()
