set(program_name perl)
set(program_version 5.40.0.1)
set(brew_package_name "perl")
set(apt_package_name "perl")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54001_64bit_UCRT/strawberry-perl-5.40.0.1-64bit-portable.zip"
    )
    set(download_filename "strawberry-perl-5.40.0.1-64bit-portable.zip")
    set(download_sha512 374a675917a3d5c03d64633e9f80e333fd0043ec0481473027045b33dc74c43cc80836b5a369b063b8b1feee5228ffc46a6508594314d19f64b9e32e8311fbb5)
    set(tool_subdirectory ${program_version})
    set(paths_to_search ${DOWNLOADS}/tools/perl/${tool_subdirectory}/perl/bin)
endif()
