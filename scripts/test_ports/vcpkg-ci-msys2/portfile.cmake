set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(msys_repo_url    "https://mirror.msys2.org/msys/x86_64")
set(mingw64_repo_url "https://mirror.msys2.org/mingw/mingw64")
set(mingw32_repo_url "https://mirror.msys2.org/mingw/mingw32")
set(clangarm64_repo_url "https://mirror.msys2.org/mingw/clangarm64")

# Ignore these updates (e.g. for known problems)
vcpkg_list(SET ignored_updates
    https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-ca-certificates-20211016-3-any.pkg.tar.zst
)

# Known removals that shall not be reported as errors
# (Packages to be removed from vcpkg scripts ASAP.)
vcpkg_list(SET known_delisted
    libcrypt
)

# Ignore these dependencies (e.g. interactive or effectively optional)
vcpkg_list(SET ignored_dependencies
    autoconf2.13 autoconf2.69 autoconf2.71
    automake1.11 automake1.12 automake1.13 automake1.14 automake1.15
    db
    gdbm
    info
    less
    libiconv-devel
    libltdl
    mingw-w64-i686-tzdata
    mingw-w64-x86_64-tzdata
)

# Ignore these provides (e.g. effectively optional)
vcpkg_list(SET ignored_provides
    gnome-common
    perl-Archive-Tar perl-Attribute-Handlers perl-AutoLoader perl-CPAN-Meta-Requirements perl-CPAN-Meta-YAML perl-CPAN-Meta perl-CPAN perl-Carp perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Config-Perl-V perl-DB_File perl-Data-Dumper perl-Devel-PPPort perl-Devel-SelfStubber perl-Digest-MD5 perl-Digest-SHA perl-Digest perl-Dumpvalue perl-Encode perl-Env perl-Exporter perl-ExtUtils-CBuilder perl-ExtUtils-Constant perl-ExtUtils-Install perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest perl-ExtUtils-PL2Bat perl-ExtUtils-ParseXS perl-File-Fetch perl-File-Path perl-File-Temp perl-Filter-Simple perl-Filter-Util-Call perl-FindBin perl-Getopt-Long perl-HTTP-Tiny perl-I18N-Collate perl-I18N-LangTags perl-IO-Compress perl-IO-Socket-IP perl-IO-Zlib perl-IO perl-IPC-Cmd perl-IPC-SysV perl-JSON-PP perl-Locale-Maketext-Simple perl-Locale-Maketext perl-MIME-Base64 perl-Math-BigInt-FastCalc perl-Math-BigInt perl-Math-BigRat perl-Math-Complex perl-Memoize perl-Module-CoreList perl-Module-Load-Conditional perl-Module-Load perl-Module-Loaded perl-Module-Metadata perl-NEXT perl-Net-Ping perl-Params-Check perl-PathTools perl-Perl-OSType perl-PerlIO-via-QuotedPrint perl-Pod-Checker perl-Pod-Escapes perl-Pod-Perldoc perl-Pod-Simple perl-Pod-Usage perl-Safe perl-Scalar-List-Utils perl-Search-Dict perl-SelfLoader perl-Socket perl-Storable perl-Sys-Syslog perl-Term-ANSIColor perl-Term-Cap perl-Term-Complete perl-Term-ReadLine perl-Test-Harness perl-Test-Simple perl-Test perl-Text-Abbrev perl-Text-Balanced perl-Text-ParseWords perl-Text-Tabs perl-Thread-Queue perl-Thread-Semaphore perl-Tie-File perl-Tie-RefHash perl-Time-HiRes perl-Time-Local perl-Time-Piece perl-Unicode-Collate perl-Unicode-Normalize perl-Win32 perl-Win32API-File perl-XSLoader perl-autodie perl-autouse perl-base perl-bignum perl-constant perl-encoding-warnings perl-experimental perl-if perl-lib perl-libnet perl-parent perl-perlfaq perl-podlators perl-threads-shared perl-threads perl-version
)


string(TIMESTAMP now "%s" UTC)

function(age_in_days out_var timestamp)
    set(age "")
    if(timestamp)
        math(EXPR age "(${now} - ${timestamp}) / 3600 / 24")
    endif()
    set(${out_var} "${age}" PARENT_SCOPE)
endfunction()

function(pretty_age out_var age_in_days)
    if(age_in_days STREQUAL "")
        set(${out_var} "(timestamp unknown)" PARENT_SCOPE)
    else()
        set(${out_var} "(${age_in_days} days ago)" PARENT_SCOPE)
    endif()
endfunction()

function(get_vcpkg_builddate out_var name)
    if(NOT DEFINED Z_VCPKG_MSYS_${name}_ARCHIVE)
        z_vcpkg_acquire_msys_download_package(Z_VCPKG_MSYS_${name}_ARCHIVE
            URL "${Z_VCPKG_MSYS_${name}_URL}"
            SHA512 "${Z_VCPKG_MSYS_${name}_SHA512}"
            FILENAME "${Z_VCPKG_MSYS_${name}_FILENAME}"
        )
        set(Z_VCPKG_MSYS_${name}_ARCHIVE "${Z_VCPKG_MSYS_${name}_ARCHIVE}" PARENT_SCOPE)
    endif()
    set(pkginfo_dir "${CURRENT_BUILDTREES_DIR}/vcpkg")
    file(REMOVE_RECURSE "${pkginfo_dir}/${name}.txt" "${pkginfo_dir}/_tmp")
    file(MAKE_DIRECTORY "${pkginfo_dir}/_tmp")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${Z_VCPKG_MSYS_${name}_ARCHIVE}" .PKGINFO
        WORKING_DIRECTORY "${pkginfo_dir}/_tmp"
    )
    file(RENAME "${pkginfo_dir}/_tmp/.PKGINFO" "${pkginfo_dir}/${name}.txt")
    file(STRINGS "${pkginfo_dir}/${name}.txt" builddate REGEX "builddate = [0-9]+")
    string(REPLACE "builddate = " "" builddate "${builddate}")
    set(${out_var} "${builddate}" PARENT_SCOPE)
endfunction()

function(get_vcpkg_provides out_var name)
    if(NOT DEFINED Z_VCPKG_MSYS_${name}_ARCHIVE)
        z_vcpkg_acquire_msys_download_package(Z_VCPKG_MSYS_${name}_ARCHIVE
            URL "${Z_VCPKG_MSYS_${name}_URL}"
            SHA512 "${Z_VCPKG_MSYS_${name}_SHA512}"
            FILENAME "${Z_VCPKG_MSYS_${name}_FILENAME}"
        )
        set(Z_VCPKG_MSYS_${name}_ARCHIVE "${Z_VCPKG_MSYS_${name}_ARCHIVE}" PARENT_SCOPE)
    endif()
    set(pkginfo_dir "${CURRENT_BUILDTREES_DIR}/vcpkg")
    file(REMOVE_RECURSE "${pkginfo_dir}/${name}.txt" "${pkginfo_dir}/_tmp")
    file(MAKE_DIRECTORY "${pkginfo_dir}/_tmp")
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${Z_VCPKG_MSYS_${name}_ARCHIVE}" .PKGINFO
        WORKING_DIRECTORY "${pkginfo_dir}/_tmp"
    )
    file(RENAME "${pkginfo_dir}/_tmp/.PKGINFO" "${pkginfo_dir}/${name}.txt")
    file(STRINGS "${pkginfo_dir}/${name}.txt" provides REGEX "provides = .+")
    string(REPLACE "provides = " "" provides "${provides}")
    set(${out_var} "${provides}" PARENT_SCOPE)
endfunction()

function(update_vcpkg_download script_file name new_url)
    message(STATUS "- Updating vcpkg...")
    if(NOT new_url MATCHES [[^https://mirror\.msys2\.org/.*/(([^/]*)-[^-/]+-[^-/]+-[^-/]+\.pkg\.tar\.(xz|zst))$]])
        message(FATAL_ERROR "Supplied URL does not match the expected pattern: ${arg_URL}")
    endif()
    set(filename "msys2-${CMAKE_MATCH_1}")
    vcpkg_download_distfile(archive
        URLS "${new_url}"
        FILENAME "${filename}"
        SKIP_SHA512
    )
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E sha512sum "${archive}"
        OUTPUT_VARIABLE sha512
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE " .*" "" sha512 "${sha512}")
    vcpkg_replace_string("${SCRIPTS}/cmake/${script_file}" "${Z_VCPKG_MSYS_${name}_URL}" "${new_url}")
    vcpkg_replace_string("${SCRIPTS}/cmake/${script_file}" "${Z_VCPKG_MSYS_${name}_SHA512}" "${sha512}")
endfunction()

function(pretty_dependencies out_var list_name)
    foreach(dependency IN LISTS ignored_dependencies)
        list(TRANSFORM ${list_name} REPLACE "^${dependency}\$" "(${dependency})")
    endforeach()
    list(JOIN ${list_name} " " list_string)
    set(${out_var} "${list_string}" PARENT_SCOPE)
endfunction()

function(analyze_package_list list_var script)
    message(STATUS "*** Analyzing packages in '${script}'")
    vcpkg_list(SET critical)         # Packages which can be upgraded and are fairly old in vcpkg
    vcpkg_list(SET mismatched_deps)  # Packages which have vcpkg deps different from msys2 deps
    vcpkg_list(SET missing)          # Packages used in (new) deps but not declared
    vcpkg_list(SET upgradable)       # Packages which can be upgrade but are fairly fresh in vcpkg
    vcpkg_list(SET vanished)         # Packages which vanished from the msys2 database

    # Preload details from direct packages
    foreach(name IN LISTS ${list_var})
        if(NOT Z_VCPKG_MSYS_${name}_DIRECT)
            continue()
        endif()
        get_vcpkg_provides(vcpkg_provides "${name}")
        set(Z_VCPKG_MSYS_${name}_PROVIDES "${vcpkg_provides}")
        foreach(provided IN LISTS vcpkg_provides)
            set(Z_VCPKG_MSYS_${provided}_PROVIDED_BY "${name}")
        endforeach()
    endforeach()

    # msys2.org removes packages 1.75 years after it was removed from the active database,
    # cf. https://www.msys2.org/docs/faq/#how-long-are-old-packages-kept-on-repomsys2org
    # We don't know the date of that replacement, and mirrors might use a shorter time.
    # But we can compare the build date of the package currently downloaded by vcpkg
    # and the build date of the package in the msys2 database.
    # If this time span exceeds 'max_age', an update is marked as critical.
    set(max_age 365) # days
    math(EXPR minimum_builddate "${now} - 6 * 30 * 24 * 3600")
    foreach(name IN LISTS ${list_var})
        if(Z_VCPKG_MSYS_${name}_DIRECT)
            message(STATUS "${name} (DIRECT)")
        elseif("DIRECT_ONLY" IN_LIST ARGN)
            continue()
        else()
            message(STATUS "${name}")
        endif()
        set(vcpkg_url "${Z_VCPKG_MSYS_${name}_URL}")
        set(vcpkg_deps "${Z_VCPKG_MSYS_${name}_DEPS}")
        set(vcpkg_provides "${Z_VCPKG_MSYS_${name}_PROVIDES}")

        set(repo "msys")
        if(name MATCHES "^mingw-w64-x86_64")
            set(repo "mingw64")
        elseif(name MATCHES "^mingw-w64-i686")
            set(repo "mingw32")
        elseif(name MATCHES "^mingw-w64-clang-aarch64")
            set(repo "clangarm64")
        endif()

        file(GLOB files "${${repo}_repo_files}/${name}-*/desc")
        set(found 0)
        foreach(file IN LISTS files)
            # Find the package
            file(STRINGS "${file}" desc)
            if(NOT desc MATCHES "%NAME%;${name};")
                continue()
            elseif(NOT desc MATCHES "%FILENAME%;([^;]+)")
                continue()
            endif()
            set(found 1)
            set(current_url "${${repo}_repo_url}/${CMAKE_MATCH_1}")
            # Check the URL
            if(NOT vcpkg_url STREQUAL current_url AND NOT current_url IN_LIST ignored_updates)
                get_vcpkg_builddate(vcpkg_builddate "${name}")
                age_in_days(vcpkg_age "${vcpkg_builddate}")
                pretty_age(vcpkg_age_pretty "${vcpkg_age}")
                set(current_age "")
                if(desc MATCHES "%BUILDDATE%;([0-9]+)")
                    age_in_days(current_age "${CMAKE_MATCH_1}")
                endif()
                pretty_age(current_age_string "${current_age}")
                message(STATUS "- vcpkg: ${vcpkg_url} ${vcpkg_age_pretty}")
                message(STATUS "+ msys2: ${current_url} ${current_age_string}")

                set(age_diff "0")
                if(NOT vcpkg_age STREQUAL "" AND NOT current_age STREQUAL "")
                    math(EXPR age_diff "${current_age} - ${vcpkg_age}")
                endif()
                if(age_diff GREATER max_age)
                    if("update-all" IN_LIST FEATURES)
                        update_vcpkg_download("${script}" "${name}" "${current_url}")
                    else()
                        vcpkg_list(APPEND critical "${name}")
                    endif()
                elseif(NOT vcpkg_url STREQUAL current_url)
                    if("update-all" IN_LIST FEATURES)
                        update_vcpkg_download("${script}" "${name}" "${current_url}")
                    else()
                        vcpkg_list(APPEND upgradable "${name}")
                    endif()
                endif()
            endif()
            # Check the dependencies
            if(desc MATCHES "%DEPENDS%;([^%]*)" OR vcpkg_deps)
                list(JOIN CMAKE_MATCH_1 " " current_deps)
                separate_arguments(current_deps UNIX_COMMAND "${current_deps}")
                list(TRANSFORM current_deps REPLACE "[<=>].*" "")
                list(SORT current_deps)
                list(SORT vcpkg_deps)
                pretty_dependencies(current_deps_string current_deps)
                if(Z_VCPKG_MSYS_${name}_DIRECT AND NOT current_deps STREQUAL "")
                    message(STATUS "* msys2 dependencies: ${current_deps_string}")
                elseif(NOT vcpkg_deps STREQUAL current_deps)
                    pretty_dependencies(vcpkg_deps_string vcpkg_deps)
                    message(STATUS "- vcpkg dependencies: ${vcpkg_deps_string}")
                    message(STATUS "+ msys2 dependencies: ${current_deps_string}")
                    list(REMOVE_ITEM current_deps ${ignored_dependencies})
                    if(NOT vcpkg_deps STREQUAL current_deps)
                        vcpkg_list(APPEND mismatched_deps "${name}")
                    endif()
                    list(REMOVE_ITEM current_deps ${known_packages} ${${list_var}} ${ignored_dependencies})
                    set(missing_deps "")
                    foreach(dep IN LISTS current_deps)
                        if(NOT DEFINED Z_VCPKG_MSYS_${dep}_PROVIDED_BY)
                            list(APPEND missing_deps "${dep}")
                        endif()
                    endforeach()
                    if(missing_deps)
                        list(JOIN missing_deps " " missing_deps_string)
                        message(STATUS "! unknown dependencies: ${missing_deps_string}")
                        vcpkg_list(APPEND missing ${missing_deps})
                    endif()
                endif()
            endif()
            # Check the "provides"
            if(desc MATCHES "%PROVIDES%;([^%]*)" OR vcpkg_provides)
                list(JOIN CMAKE_MATCH_1 " " current_provides)
                separate_arguments(current_provides UNIX_COMMAND "${current_provides}")
                list(TRANSFORM current_provides REPLACE "[<=>].*" "")
                list(REMOVE_ITEM current_provides ${ignored_provides})
                list(JOIN vcpkg_provides " " vcpkg_provides_string)
                if(NOT vcpkg_provides STREQUAL current_provides)
                    list(JOIN vcpkg_provides " " vcpkg_provides_string)
                    list(JOIN current_provides " " current_provides_string)
                    message(STATUS "- vcpkg provides: ${vcpkg_provides_string}")
                    message(STATUS "+ msys2 provides: ${current_provides_string}")
                elseif(NOT vcpkg_provides STREQUAL "")
                    message(STATUS "* provides: ${vcpkg_provides_string}")
                endif()
            endif()
        endforeach()
        if(NOT found AND NOT name IN_LIST known_delisted)
            vcpkg_list(APPEND vanished "${name}")
            get_vcpkg_builddate(vcpkg_builddate "${name}")
            age_in_days(vcpkg_age "${vcpkg_builddate}")
            pretty_age(vcpkg_age_pretty "${vcpkg_age}")
            message(STATUS "- vcpkg: ${vcpkg_url} ${vcpkg_age_pretty}")
            message(STATUS "! msys2: no match for ${name}")

            age_in_days(current_age "${now}")
            set(age_diff "0")
            if(NOT vcpkg_age STREQUAL "" AND NOT current_age STREQUAL "")
                math(EXPR age_diff "${current_age} - ${vcpkg_age}")
            endif()
            if(age_diff GREATER max_age)
                vcpkg_list(APPEND critical "${name}")
            endif()
        endif()
    endforeach()

    if(mismatched_deps)
        list(JOIN mismatched_deps " " mismatched_deps)
        message(WARNING "The following msys2 packages have changed dependencies: ${mismatched_deps}")
    endif()
    if(missing)
        list(SORT missing)
        list(REMOVE_DUPLICATES missing)
        list(JOIN missing " " missing)
        message(WARNING "The following msys2 packages would be needed to update all dependencies: ${missing}")
    endif()
    if(upgradable)
        list(JOIN upgradable " " upgradable)
        message(WARNING "The following msys2 packages could be updated: ${upgradable}")
    endif()
    if(critical)
        list(JOIN critical " " critical)
        message(SEND_ERROR "The following msys2 packages were build more than 6 months ago and should be updated: ${critical}")
    endif()
    if(vanished)
        list(JOIN vanished " " vanished)
        message(SEND_ERROR "The following msys2 packages are no longer in the database: ${vanished}")
    endif()
    message(STATUS "*** Analyzing packages in '${script}' done")
endfunction()

message(STATUS "*** Downloading current msys2 package lists")
string(TIMESTAMP stamp "%Y-%m-%d" UTC)
foreach(repo IN ITEMS msys mingw32 mingw64 clangarm64)
    string(REPLACE "/" "-" local_file "msys2-${stamp}-${repo}.files")
    set(archive "${DOWNLOADS}/${local_file}")
    vcpkg_download_distfile(repo_files_archive
        URLS "${${repo}_repo_url}/${repo}.files"
        FILENAME "${local_file}"
        SKIP_SHA512
    )
    vcpkg_extract_source_archive(repo_files
        ARCHIVE "${repo_files_archive}"
        NO_REMOVE_ONE_LEVEL
    )
    set(${repo}_repo_files "${repo_files}")
endforeach()
message(STATUS "*** Downloading current msys2 package lists done")

set(Z_VCPKG_MSYS_PACKAGES_RESOLVED "" CACHE INTERNAL "")
vcpkg_acquire_msys(msys_root Z_ALL_PACKAGES)
analyze_package_list(Z_VCPKG_MSYS_PACKAGES_RESOLVED "vcpkg_acquire_msys.cmake")
set(known_packages "${Z_VCPKG_MSYS_PACKAGES_RESOLVED}")

set(Z_VCPKG_MSYS_PACKAGES_RESOLVED "" CACHE INTERNAL "")
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_acquire_msys(msys_root
    NO_DEFAULT_PACKAGES
    Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_acquire_pkgconfig_msys_declare_packages"
    PACKAGES
        mingw-w64-clang-aarch64-pkgconf
        mingw-w64-x86_64-pkgconf
        mingw-w64-i686-pkgconf
)
analyze_package_list(Z_VCPKG_MSYS_PACKAGES_RESOLVED "vcpkg_find_acquire_program(PKGCONFIG).cmake")

set(CMAKE_Fortran_COMPILER "")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(CMAKE_Fortran_COMPILER "true")
endif()
set(Z_VCPKG_MSYS_PACKAGES_RESOLVED "" CACHE INTERNAL "")
include("${SCRIPTS}/cmake/vcpkg_find_fortran.cmake")
vcpkg_find_fortran(FORTRAN)
vcpkg_acquire_msys(msys_root
    NO_DEFAULT_PACKAGES
    Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_fortran_msys_declare_packages"
    PACKAGES
        mingw-w64-x86_64-gcc-fortran
        mingw-w64-i686-gcc-fortran
)
analyze_package_list(Z_VCPKG_MSYS_PACKAGES_RESOLVED "vcpkg_find_fortran.cmake")
