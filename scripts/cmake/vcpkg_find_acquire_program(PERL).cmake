set(program_name perl)
set(program_version 5.42.0.1)
set(brew_package_name "perl")
set(apt_package_name "perl")
if(CMAKE_HOST_WIN32)
    set(download_urls
        "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54201_64bit/strawberry-perl-5.42.0.1-64bit-portable.zip"
    )
    set(download_filename "strawberry-perl-5.42.0.1-64bit-portable.zip")
    set(download_sha512 e78fc86eb76dc34f2fd8a911537b20378e1ce486a3ea1a167001fd040c2468e8db5e711a895314e7ead3511f3caafccc1ffbfd0bd4096c0360d712a9668fe69b)
    set(tool_subdirectory ${program_version})
    set(paths_to_search ${DOWNLOADS}/tools/perl/${tool_subdirectory}/perl/bin)
endif()
