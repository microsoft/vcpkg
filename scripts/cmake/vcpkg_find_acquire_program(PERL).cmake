set(program_name perl)
set(program_version 5.40.2.1)
set(brew_package_name "perl")
set(apt_package_name "perl")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54021_64bit_UCRT/strawberry-perl-5.40.2.1-64bit-portable.zip"
    )
    set(download_filename "strawberry-perl-5.40.2.1-64bit-portable.zip")
    set(download_sha512 a9dbd9e7d77398971a8e768a0f179cf6dc0d9fc68406735691470c48dd0d8d19ba1f60bedf1967a916beea5fdcdd43c7b18a25884b1ab1a2f19fbb8950f7da19)
    set(tool_subdirectory ${program_version})
    set(paths_to_search ${DOWNLOADS}/tools/perl/${tool_subdirectory}/perl/bin)
endif()
