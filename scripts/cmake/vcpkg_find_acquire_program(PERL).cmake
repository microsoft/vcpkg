set(program_name perl)
set(program_version 5.42.2.1)
set(brew_package_name "perl")
set(apt_package_name "perl")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip"
    )
    set(download_filename "strawberry-perl-5.42.2.1-64bit-portable.zip")
    set(download_sha512 e37c541bb6c4f1c0187bf8ba22b19ce9ead87f6bd1e68c05e7fc4eb2c10a4183c3ee732bf1b26071939f525861fae62b6bef04100b31504ab50fffe7526f84e3)
    set(tool_subdirectory ${program_version})
    set(paths_to_search ${DOWNLOADS}/tools/perl/${tool_subdirectory}/perl/bin)
endif()
