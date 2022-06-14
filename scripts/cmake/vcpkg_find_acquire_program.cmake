function(z_vcpkg_find_acquire_program_version_check out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "MIN_VERSION;PROGRAM_NAME"
        "COMMAND"
    )
    vcpkg_execute_in_download_mode(
        COMMAND ${arg_COMMAND}
        WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
        OUTPUT_VARIABLE program_version_output
    )
    string(STRIP "${program_version_output}" program_version_output)
    #TODO: REGEX MATCH case for more complex cases!
    set(version_compare VERSION_GREATER_EQUAL)
    set(version_compare_msg "at least")
    if(arg_EXACT_VERSION_MATCH)
        set(version_compare VERSION_EQUAL)
        set(version_compare_msg "exact")
    endif()
    if(NOT "${program_version_output}" ${version_compare} "${arg_MIN_VERSION}")
        message(STATUS "Found ${arg_PROGRAM_NAME}('${program_version_output}') but ${version_compare_msg} version ${arg_MIN_VERSION} is required! Trying to use internal version if possible!")
        set("${out_var}" OFF PARENT_SCOPE)
    else()
        message(STATUS "Found external ${arg_PROGRAM_NAME}('${program_version_output}').")
        set("${out_var}" ON PARENT_SCOPE)
    endif()
endfunction()

function(z_vcpkg_find_acquire_program_find_external program)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "EXACT_VERSION_MATCH"
        "INTERPRETER;MIN_VERSION;PROGRAM_NAME"
        "NAMES;VERSION_COMMAND"
    )
    if(arg_EXACT_VERSION_MATCH)
        set(arg_EXACT_VERSION_MATCH EXACT_VERSION_MATCH)
    endif()

    if("${arg_INTERPRETER}" STREQUAL "")
        find_program("${program}" NAMES ${arg_NAMES})
    else()
        find_file(SCRIPT_${arg_PROGRAM_NAME} NAMES ${arg_NAMES})
        if(SCRIPT_${arg_PROGRAM_NAME})
            vcpkg_list(SET program_tmp ${${interpreter}} ${SCRIPT_${arg_PROGRAM_NAME}})
            set("${program}" "${program_tmp}" CACHE INTERNAL "")
        else()
            set("${program}" "" CACHE INTERNAL "")
        endif()
        unset(SCRIPT_${arg_PROGRAM_NAME} CACHE)
    endif()

    if("${version_command}" STREQUAL "")
        set(version_is_good ON) # can't check for the version being good, so assume it is
    elseif(${program}) # only do a version check if ${program} has a value
        z_vcpkg_find_acquire_program_version_check(version_is_good
            ${arg_EXACT_VERSION_MATCH}
            COMMAND ${${program}} ${arg_VERSION_COMMAND}
            MIN_VERSION "${arg_MIN_VERSION}"
            PROGRAM_NAME "${arg_PROGRAM_NAME}"
        )
    endif()

    if(NOT version_is_good)
        unset("${program}" PARENT_SCOPE)
        unset("${program}" CACHE)
    endif()
endfunction()

function(z_vcpkg_find_acquire_program_find_internal program)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "INTERPRETER"
        "NAMES;PATHS"
    )
    if("${arg_INTERPRETER}" STREQUAL "")
        find_program(${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
    else()
        vcpkg_find_acquire_program("${arg_INTERPRETER}")
        find_file(SCRIPT_${program}
            NAMES ${arg_NAMES}
            PATHS ${arg_PATHS}
            NO_DEFAULT_PATH)
        if(SCRIPT_${program})
            set("${program}" ${${arg_INTERPRETER}} ${SCRIPT_${program}} CACHE INTERNAL "")
        endif()
        unset(SCRIPT_${program} CACHE)
    endif()
endfunction()

function(vcpkg_find_acquire_program program)
    if(${program})
        return()
    endif()

    set(raw_executable "OFF")
    set(program_name "")
    set(program_version "")
    set(search_names "")
    set(download_urls "")
    set(download_filename "")
    set(download_sha512 "")
    set(rename_binary_to "")
    set(tool_subdirectory "")
    set(interpreter "")
    set(supported_on_unix "")
    set(post_install_command "")
    set(paths_to_search "")
    set(version_command "")
    vcpkg_list(SET sourceforge_args)
    set(brew_package_name "")
    set(apt_package_name "")

    if(program STREQUAL "PERL")
        set(program_name perl)
        set(program_version 5.32.1.1)
        set(tool_subdirectory ${program_version})
        set(paths_to_search ${DOWNLOADS}/tools/perl/${tool_subdirectory}/perl/bin)
        set(brew_package_name "perl")
        set(apt_package_name "perl")
        set(download_urls
            "https://strawberryperl.com/download/${program_version}/strawberry-perl-${program_version}-32bit.zip"
        )
        set(download_filename "strawberry-perl-${program_version}-32bit.zip")
        set(download_sha512 936381254fea2e596db6a16c23b08ced25c4081fda484e1b8c4356755016e4b956bd00f3d2ee651d5f41a7695e9998f6c1ac3f4a237212b9c55aca8c5fea14e9)
    elseif(program STREQUAL "NASM")
        set(program_name nasm)
        set(program_version 2.15.05)
        set(paths_to_search "${DOWNLOADS}/tools/nasm/nasm-${program_version}")
        set(brew_package_name "nasm")
        set(apt_package_name "nasm")
        set(download_urls
            "https://www.nasm.us/pub/nasm/releasebuilds/${program_version}/win32/nasm-${program_version}-win32.zip"
            "https://fossies.org/windows/misc/nasm-${program_version}-win32.zip"
        )
        set(download_filename "nasm-${program_version}-win32.zip")
        set(download_sha512 9412b8caa07e15eac8f500f6f8fab9f038d95dc25e0124b08a80645607cf5761225f98546b52eac7b894420d64f26c3cbf22c19cd286bbe583f7c964256c97ed)
    elseif(program STREQUAL "YASM")
        set(program_name yasm)
        set(program_version 1.3.0.6.g1962)
        set(tool_subdirectory 1.3.0.6)
        set(brew_package_name "yasm")
        set(apt_package_name "yasm")
        set(download_urls "https://www.tortall.net/projects/yasm/snapshots/v${program_version}/yasm-${program_version}.exe")
        set(download_filename "yasm-${program_version}.exe")
        set(rename_binary_to "yasm.exe")
        set(raw_executable ON)
        set(download_sha512 c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
    elseif(program STREQUAL "GIT")
        set(program_name git)
        if(CMAKE_HOST_WIN32)
            set(base_version 2.32.0)
            set(program_version 2.32.0.2)
            set(tool_subdirectory "git-${program_version}-2-windows")
            set(download_urls "https://github.com/git-for-windows/git/releases/download/v${base_version}.windows.2/PortableGit-${program_version}-32-bit.7z.exe")
            set(download_filename "PortableGit-${program_version}-32-bit.7z.exe")
            set(download_sha512 867d8534972cbaf7a4224e25a14d484f8d17ef186f8d79e9a758afb90cf69541375cb7615a39702311f4809cb8371ef85c2b1a15bfffe9e48f0e597ac011b348)
            set(paths_to_search
                "${DOWNLOADS}/tools/${tool_subdirectory}/mingw32/bin"
                "${DOWNLOADS}/tools/git/${tool_subdirectory}/mingw32/bin")
        else()
            set(brew_package_name "git")
            set(apt_package_name "git")
        endif()
    elseif(program STREQUAL "GN")
        set(program_name gn)
        set(rename_binary_to "gn")
        if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/share/gn/version.txt")
            file(READ "${CURRENT_HOST_INSTALLED_DIR}/share/gn/version.txt" program_version)
            set(paths_to_search "${CURRENT_HOST_INSTALLED_DIR}/tools/gn")
        else() # Old behavior
            message("Consider adding vcpkg-tool-gn as a host dependency of this port or create an issue at https://github.com/microsoft/vcpkg/issues")
            set(cipd_download_gn "https://chrome-infra-packages.appspot.com/dl/gn/gn")
            if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
                set(supported_on_unix ON)
                EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH)
                if(HOST_ARCH STREQUAL "aarch64")
                    set(program_version "GkfFAfAUyE-qfeWkdUMaeM1Ov64Fk3SjSj9pwKqZX7gC")
                    set(gn_platform "linux-arm64")
                    set(download_sha512 "E88201309A12C00CE60137261B8E1A759780C81D1925B819583B16D2095A16A7D32EFB2AF36C1E1D6EAA142BF6A6A811847D3140E4E94967EE28F4ADF6373E4B")
                else()
                    set(program_version "Fv1ENXodhXmEXy_xpZr2gQkVJh57w_IsbsrEJOU0_EoC")
                    set(gn_platform "linux-amd64")
                    set(download_sha512 "A7A5CD5633C5547EC1B1A95958486DDAAC91F1A65881EDC0AD8F74DF44E82F08BA74358E9A72DFCDDE6F534A6B9C9A430D3E16ACE2E4346C4D2E9113F7654B3F")
                endif()
            elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
                set(supported_on_unix ON)
                EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH)
                if(HOST_ARCH STREQUAL "arm64")
                    set(program_version "qMPtGq7xZlpb-lHjP-SK27ftT4X71WIvguuyx6X14DEC")
                    set(gn_platform "mac-arm64")
                    set(download_sha512 "D096FB958D017807427911089AB5A7655AED117F6851C0491AC8063CEDB544423122EF64DF4264ECA86C20A2BDE9E64D7B72DA7ED8C95C2BA79A68B8247D36B8")
                else()
                    set(program_version "0x2juPLNfP9603GIyZrUfflxK6LiMcppLAoxEpYuIYoC")
                    set(gn_platform "mac-amd64")
                    set(download_sha512 "2696ECE7B2C8008CABDDF10024017E2ECF875F8679424E77052252BDDC83A2096DF3C61D89CD25120EF27E0458C8914BEEED9D418593BDBC4F6ED33A8D4C3DC5")
                endif()
            else()
                if($ENV{PROCESSOR_ARCHITECTURE} STREQUAL "ARM64")
                    set(program_version "q5ExVHmXyD34Q_Tzb-aRxsPipO-e37-csVRhVM7IJh0C")
                    set(gn_platform "windows-amd64")
                    set(download_sha512 "FA764AA44EB6F48ED50E855B4DC1DD1ABE35E45FD4AAC7F059A35293A14894C1B591215E34FB0CE9362E646EA9463BA3B489EFB7EBBAA2693D14238B50E4E686")
                else() # AMD64
                    set(program_version "q5ExVHmXyD34Q_Tzb-aRxsPipO-e37-csVRhVM7IJh0C")
                    set(gn_platform "windows-amd64")
                    set(download_sha512 "FA764AA44EB6F48ED50E855B4DC1DD1ABE35E45FD4AAC7F059A35293A14894C1B591215E34FB0CE9362E646EA9463BA3B489EFB7EBBAA2693D14238B50E4E686")
                endif()
            endif()
        endif()
        set(tool_subdirectory "${program_version}")
        set(download_urls "${cipd_download_gn}/${gn_platform}/+/${program_version}")
        set(download_filename "gn-${gn_platform}.zip")
    elseif(program STREQUAL "GO")
        set(program_name go)
        set(tool_subdirectory 1.16.6.windows-386)
        set(paths_to_search ${DOWNLOADS}/tools/go/${tool_subdirectory}/go/bin)
        set(brew_package_name "go")
        set(apt_package_name "golang-go")
        set(download_urls "https://dl.google.com/go/go${tool_subdirectory}.zip")
        set(download_filename "go${tool_subdirectory}.zip")
        set(download_sha512 2a1e539ed628c0cca5935d24d22cf3a7165f5c80e12a4003ac184deae6a6d0aa31f582f3e8257b0730adfc09aeec3a0e62f4732e658c312d5382170bcd8c94d8)
    elseif(program STREQUAL "PYTHON3")
        if(CMAKE_HOST_WIN32)
            set(program_name python)
            set(program_version 3.10.2)
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(tool_subdirectory "python-${program_version}-x86")
                set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-win32.zip")
                set(download_filename "python-${program_version}-embed-win32.zip")
                set(download_sha512 d647d7141d1b13c899671b882e686a1b1cc6f759e5b7428ec858cdffd9ef019c78fb0b989174b98f30cb696297bfeff3d171f7eaabb339f5154886c030b8e4d9)
            else()
                set(tool_subdirectory "python-${program_version}-x64")
                set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}-embed-amd64.zip")
                set(download_filename "python-${program_version}-embed-amd64.zip")
                set(download_sha512 e04e14f3b5e96f120a3b0d5fac07b2982b9f3394aef4591b140e84ff97c8532e1f8bf3e613bdf5aec6afeac108b975e754bf9727354bcfaa6673fc89826eac37)
            endif()
            set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")
            vcpkg_list(SET post_install_command "${CMAKE_COMMAND}" -E rm python310._pth)
        else()
            set(program_name python3)
            set(brew_package_name "python")
            set(apt_package_name "python3")
        endif()
    elseif(program STREQUAL "PYTHON2")
        if(CMAKE_HOST_WIN32)
            set(program_name python)
            set(program_version 2.7.18)
            if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-tool-python2/details.cmake")
                include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-tool-python2/details.cmake")
            else() # Old behavior
                if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                    set(tool_subdirectory "python-${program_version}-x86")
                    set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}.msi")
                    set(download_filename "python-${program_version}.msi")
                    set(download_sha512 2c112733c777ddbf189b0a54047a9d5851ebce0564cc38b9687d79ce6c7a09006109dbad8627fb1a60c3ad55e261db850d9dfa454af0533b460b2afc316fe115)
                else()
                    set(tool_subdirectory "python-${program_version}-x64")
                    set(download_urls "https://www.python.org/ftp/python/${program_version}/python-${program_version}.amd64.msi")
                    set(download_filename "python-${program_version}.amd64.msi")
                    set(download_sha512 6a81a413b80fd39893e7444fd47efa455d240cbb77a456c9d12f7cf64962b38c08cfa244cd9c50a65947c40f936c6c8c5782f7236d7b92445ab3dd01e82af23e)
                endif()
                set(paths_to_search "${DOWNLOADS}/tools/python/${tool_subdirectory}")
            endif()
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
            # macOS includes Python 2.7 built-in as `python`
            set(program_name python)
            set(brew_package_name "python2")
        else()
            set(program_name python2)
            set(apt_package_name "python")
        endif()
    elseif(program STREQUAL "RUBY")
        set(program_name "ruby")
        set(program_version 2.7.4-1)
        set(paths_to_search "${DOWNLOADS}/tools/ruby/rubyinstaller-${program_version}-x86/bin")
        set(download_urls "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-${program_version}/rubyinstaller-${program_version}-x86.7z")
        set(download_filename "rubyinstaller-${program_version}-x86.7z")
        set(download_sha512 4bf459c987b407bdda328c52d95060bf6ad48fc3e5ed5f64d4b205c5b4153c7a00cb6f9da6c0bcd5f2e001e9dc3dda0b72269ec4afdeffd658b93c085cd1d859)
    elseif(program STREQUAL "JOM")
        set(program_name jom)
        set(tool_subdirectory "jom-1.1.3")
        set(paths_to_search "${DOWNLOADS}/tools/jom/${tool_subdirectory}")
        set(download_urls
            "https://download.qt.io/official_releases/jom/jom_1_1_3.zip"
            "https://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_1_1_3.zip"
        )
        set(download_filename "jom_1_1_3.zip")
        set(download_sha512 5b158ead86be4eb3a6780928d9163f8562372f30bde051d8c281d81027b766119a6e9241166b91de0aa6146836cea77e5121290e62e31b7a959407840fc57b33)
    elseif(program STREQUAL "7Z")
        set(program_name 7z)
        set(paths_to_search "${DOWNLOADS}/tools/7z/Files/7-Zip")
        set(download_urls "https://7-zip.org/a/7z1900.msi")
        set(download_filename "7z1900.msi")
        set(download_sha512 f73b04e2d9f29d4393fde572dcf3c3f0f6fa27e747e5df292294ab7536ae24c239bf917689d71eb10cc49f6b9a4ace26d7c122ee887d93cc935f268c404e9067)
    elseif(program STREQUAL "NINJA")
        set(program_name ninja)
        set(program_version 1.10.2)
        set(supported_on_unix ON)
        if(CMAKE_HOST_WIN32)
            set(download_filename "ninja-win-${program_version}.zip")
            set(tool_subdirectory "${program_version}-windows")
            set(download_urls "https://github.com/ninja-build/ninja/releases/download/v${program_version}/ninja-win.zip")
            set(download_sha512 6004140d92e86afbb17b49c49037ccd0786ce238f340f7d0e62b4b0c29ed0d6ad0bab11feda2094ae849c387d70d63504393714ed0a1f4d3a1f155af7a4f1ba3)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
            set(download_filename "ninja-mac-${program_version}.zip")
            set(download_urls "https://github.com/ninja-build/ninja/releases/download/v${program_version}/ninja-mac.zip")
            set(tool_subdirectory "${program_version}-osx")
            set(paths_to_search "${DOWNLOADS}/tools/ninja-${program_version}-osx")
            set(download_sha512 bcd12f6a3337591306d1b99a7a25a6933779ba68db79f17c1d3087d7b6308d245daac08df99087ff6be8dc7dd0dcdbb3a50839a144745fa719502b3a7a07260b)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
            set(paths_to_search "${DOWNLOADS}/tools/${tool_subdirectory}-freebsd")
            set(supported_on_unix OFF)
        else()
            set(download_filename "ninja-linux-${program_version}.zip")
            set(download_urls "https://github.com/ninja-build/ninja/releases/download/v${program_version}/ninja-linux.zip")
            set(tool_subdirectory "${program_version}-linux")
            set(paths_to_search "${DOWNLOADS}/tools/ninja-${program_version}-linux")
            set(download_sha512 93e802e9c17fb59636cddde4bad1ddaadad624f4ecfee00d5c78790330a4e9d433180e795718cda27da57215ce643c3929cf72c85337ee019d868c56f2deeef3)
        endif()
        set(version_command --version)
    elseif(program STREQUAL "NUGET")
        set(program_name nuget)
        set(tool_subdirectory "5.11.0")
        set(paths_to_search "${DOWNLOADS}/tools/nuget-${tool_subdirectory}-windows")
        set(brew_package_name "nuget")
        set(download_urls "https://dist.nuget.org/win-x86-commandline/v5.11.0/nuget.exe")
        set(rename_binary_to "nuget.exe")
        set(download_filename "nuget.5.11.0.exe")
        set(raw_executable ON)
        set(download_sha512 06a337c9404dec392709834ef2cdbdce611e104b510ef40201849595d46d242151749aef65bc2d7ce5ade9ebfda83b64c03ce14c8f35ca9957a17a8c02b8c4b7)
    elseif(program STREQUAL "MESON") # Should always be found!
        set(program_name meson)
        set(search_names meson meson.py)
        set(interpreter PYTHON3)
        set(apt_package_name "meson")
        set(brew_package_name "meson")
        set(version_command --version)
        set(extra_search_args EXACT_VERSION_MATCH)
        if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/share/meson/version.txt")
            file(READ "${CURRENT_HOST_INSTALLED_DIR}/share/meson/version.txt" program_version)
            set(paths_to_search "${CURRENT_HOST_INSTALLED_DIR}/tools/meson")
        else() # Old behavior
            set(program_version 0.58.1)
            set(ref aeda7f249c4a5dbbecc52e44f382246a2377b5b0)
            set(paths_to_search "${DOWNLOADS}/tools/meson/meson-${ref}")
            set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
            set(download_filename "meson-${ref}.tar.gz")
            set(download_sha512 18a012a45274dbb4582e99fd69d920f38831e788d9860f9553c64847bedb1c2010ae0b5c0ef4a4350c03f5e0f95aaa0395378e1208109b59640c1a70b1e202d2)
            set(supported_on_unix ON)
        endif()
    elseif(program STREQUAL "FLEX" OR program STREQUAL "BISON")
        if(CMAKE_HOST_WIN32)
            set(program_version 2.5.25)
            set(download_urls "https://github.com/lexxmark/winflexbison/releases/download/v${program_version}/win_flex_bison-${program_version}.zip")
            set(download_filename "win_flex_bison-${program_version}.zip")
            set(download_sha512 2a829eb05003178c89f891dd0a67add360c112e74821ff28e38feb61dac5b66e9d3d5636ff9eef055616aaf282ee8d6be9f14c6ae4577f60bdcec96cec9f364e)
            set(tool_subdirectory "${program_version}")
            if(program STREQUAL "FLEX")
                set(program_name win_flex)
            else()
                set(program_name win_bison)
            endif()
            set(paths_to_search ${DOWNLOADS}/tools/win_flex/${program_version})
            if(NOT EXISTS "${paths_to_search}/data/m4sugar/m4sugar.m4")
                file(REMOVE_RECURSE "${paths_to_search}")
            endif()
        elseif(program STREQUAL "FLEX")
            set(program_name flex)
            set(apt_package_name flex)
            set(brew_package_name flex)
        else()
            set(program_name bison)
            set(apt_package_name bison)
            set(brew_package_name bison)
            if (APPLE)
                set(paths_to_search /usr/local/opt/bison/bin)
            endif()
        endif()
    elseif(program STREQUAL "CLANG")
        set(program_name clang)
        set(tool_subdirectory "clang-12.0.0")
        set(program_version 12.0.0)
        if(CMAKE_HOST_WIN32)
            set(paths_to_search
                # Support LLVM in Visual Studio 2019
                "$ENV{LLVMInstallDir}/x64/bin"
                "$ENV{LLVMInstallDir}/bin"
                "$ENV{VCINSTALLDIR}/Tools/Llvm/x64/bin"
                "$ENV{VCINSTALLDIR}/Tools/Llvm/bin"
                "${DOWNLOADS}/tools/${tool_subdirectory}-windows/bin"
                "${DOWNLOADS}/tools/clang/${tool_subdirectory}/bin")

            if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
                set(host_arch "$ENV{PROCESSOR_ARCHITEW6432}")
            else()
                set(host_arch "$ENV{PROCESSOR_ARCHITECTURE}")
            endif()

            if(host_arch MATCHES "64")
                set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win64.exe")
                set(download_filename "LLVM-${program_version}-win64.7z.exe")
                set(download_sha512 67a9b54abad5143fa5f79f0cfc184be1394c9fc894fa9cee709943cb6ccbde8f0ea6003d8fcc20eccf035631abe4009cc0f694ac84e7879331cebba8125e4c7f)
            else()
                set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win32.exe")
                set(download_filename "LLVM-${program_version}-win32.7z.exe")
                set(download_sha512 92fa5252fd08c1414ee6d71e2544cd2c44872124c47225f8d98b3af711d20e699f2888bc30642dfd00e005013da1607a593674fb4878951cc434694f9a119199)
            endif()
        endif()
        set(brew_package_name "llvm")
        set(apt_package_name "clang")
    elseif(program STREQUAL "GPERF")
        set(program_name gperf)
        set(program_version 3.0.1)
        set(paths_to_search "${DOWNLOADS}/tools/gperf/bin")
        set(download_urls "https://sourceforge.net/projects/gnuwin32/files/gperf/${program_version}/gperf-${program_version}-bin.zip/download")
        set(download_filename "gperf-${program_version}-bin.zip")
        set(download_sha512 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
    elseif(program STREQUAL "GASPREPROCESSOR")
        set(raw_executable true)
        set(program_name gas-preprocessor)
        set(tool_subdirectory "4daa6115")
        set(interpreter PERL)
        set(search_names "gas-preprocessor.pl")
        set(paths_to_search "${DOWNLOADS}/tools/gas-preprocessor/${tool_subdirectory}")
        set(rename_binary_to "gas-preprocessor.pl")
        set(download_urls "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/4daa611556a0558dfe537b4f7ad80f7e50a079c1/gas-preprocessor.pl")
        set(download_filename "gas-preprocessor-${tool_subdirectory}.pl")
        set(download_sha512 2737ba3c1cf85faeb1fbfe015f7bad170f43a857a50a1b3d81fa93ba325d481f73f271c5a886ff8b7eef206662e19f0e9ef24861dfc608b67b8ea8a2062dc061)
    elseif(program STREQUAL "DARK")
        set(program_name dark)
        set(tool_subdirectory "wix311-binaries")
        set(paths_to_search "${DOWNLOADS}/tools/dark/${tool_subdirectory}")
        set(download_urls "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
        set(download_filename "wix311-binaries.zip")
        set(download_sha512 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
    elseif(program STREQUAL "SCONS")
        set(program_name scons)
        set(program_version 4.1.0)
        set(tool_subdirectory "${program_version}")
        set(interpreter PYTHON2)
        set(search_names "scons.py")
        set(download_urls "https://sourceforge.net/projects/scons/files/scons-local-${program_version}.zip/download")
        set(download_filename "scons-local-${program_version}.zip")
        set(download_sha512 b173176ce8aca25039c64fcc68ec1b9ad31e03a926fd545e7631b3f9b374d914adffc593f505e3e7e2867b0ffe85e8deb0b39afe314edf05d02974ce5db1badb)
    elseif(program STREQUAL "SWIG")
        set(program_version 4.0.2)
        set(program_name swig)
        if(CMAKE_HOST_WIN32)
            vcpkg_list(SET sourceforge_args
                REPO swig/swigwin
                REF "swigwin-${program_version}"
                FILENAME "swigwin-${program_version}.zip"
                SHA512 b8f105f9b9db6acc1f6e3741990915b533cd1bc206eb9645fd6836457fd30789b7229d2e3219d8e35f2390605ade0fbca493ae162ec3b4bc4e428b57155db03d
                NO_REMOVE_ONE_LEVEL
                WORKING_DIRECTORY "${DOWNLOADS}/tools/swig"
            )
            set(tool_subdirectory "b8f105f9b9-f0518bc3b7/swigwin-${program_version}")
        else()
            set(apt_package_name "swig")
            set(brew_package_name "swig")
        endif()

    elseif(program STREQUAL "DOXYGEN")
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
    elseif(program STREQUAL "BAZEL")
        set(program_name bazel)
        set(program_version 4.2.2)
        set(rename_binary_to "bazel")
        if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
            set(supported_on_unix ON)
            set(tool_subdirectory "${program_version}-linux")
            set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64")
            set(download_filename "bazel-${tool_subdirectory}-x86_64")
            set(raw_executable ON)
            set(download_sha512 f38619e054df78cab38278a5901b2798f2e25b5cec53358d98278002e713d225fd3df96a209b7f22a2357835a279cee8ef1768e10561b3e9fe6361f324563bb9)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
            set(supported_on_unix ON)
            set(tool_subdirectory "${program_version}-darwin")
            set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64")
            set(download_filename "bazel-${tool_subdirectory}-x86_64")
            set(raw_executable ON)
            set(download_sha512 a3fd8f9d71b0669d742439200f27ee0a3891c1f248df62c841ebb2b416a47534562f429f8a08793b074e9b74f2ede3d97a7e13ac9921c7ee2dc6a2dca8b7f275)
        else()
            set(tool_subdirectory "${program_version}-windows")
            set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${program_version}/bazel-${tool_subdirectory}-x86_64.zip")
            set(download_filename "bazel-${tool_subdirectory}-x86_64.zip")
            set(download_sha512 8a8196e242964114316232818cb81bfa19ebfd3a029ebf550a241e33b22a6e9ed636dade06411a8706c05c4e73def0bc8d7f45ff0ec5478bcc5de21b5638204d)
        endif()
    elseif(program STREQUAL "ARIA2")
        set(program_name aria2c)
        set(program_version 1.35.0)
        set(paths_to_search "${DOWNLOADS}/tools/aria2c/aria2-${program_version}-win-32bit-build1")
        set(download_urls "https://github.com/aria2/aria2/releases/download/release-${program_version}/aria2-${program_version}-win-32bit-build1.zip")
        set(download_filename "aria2-${program_version}-win-32bit-build1.zip")
        set(download_sha512 933537cad820b1cecf43a9eeca7e1b241dd7b1c902ee942441a166f2c38845f16046321efbdfa2f83c7e9fc50c7ecc5da6fd00e0c6e2124c07d3b783aa5092a4)
    elseif(program STREQUAL "PKGCONFIG")
        set(program_name pkg-config)
        if(DEFINED ENV{PKG_CONFIG})
            debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
            set(PKGCONFIG "$ENV{PKG_CONFIG}" CACHE INTERNAL "")
            set(PKGCONFIG "${PKGCONFIG}" PARENT_SCOPE)
            return()
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "OpenBSD")
            # As of 6.8, the OpenBSD specific pkg-config doesn't support {pcfiledir}
            set(supported_on_unix ON)
            set(rename_binary_to "pkg-config")
            set(program_version 0.29.2.1)
            set(raw_executable ON)
            set(download_filename "pkg-config.openbsd")
            set(tool_subdirectory "openbsd")
            set(download_urls "https://raw.githubusercontent.com/jgilje/pkg-config-openbsd/master/pkg-config")
            set(download_sha512 b7ec9017b445e00ae1377e36e774cf3f5194ab262595840b449832707d11e443a102675f66d8b7e8b2e2f28cebd6e256835507b1e0c69644cc9febab8285080b)
            set(version_command --version)
        elseif(CMAKE_HOST_WIN32)
            if(NOT EXISTS "${PKGCONFIG}")
                set(VERSION 0.29.2-3)
                set(program_version git-9.0.0.6373.5be8fcd83-1)
                vcpkg_acquire_msys(
                    PKGCONFIG_ROOT
                    NO_DEFAULT_PACKAGES
                    DIRECT_PACKAGES
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-pkg-config-${VERSION}-any.pkg.tar.zst"
                        0c086bf306b6a18988cc982b3c3828c4d922a1b60fd24e17c3bead4e296ee6de48ce148bc6f9214af98be6a86cb39c37003d2dcb6561800fdf7d0d1028cf73a4
                        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-${program_version}-any.pkg.tar.zst"
                        c89c27b5afe4cf5fdaaa354544f070c45ace5e9d2f2ebb4b956a148f61681f050e67976894e6f52e42e708dadbf730fee176ac9add3c9864c21249034c342810
                )
            endif()
            set("${program}" "${PKGCONFIG_ROOT}/mingw32/bin/pkg-config.exe" CACHE INTERNAL "")
            set("${program}" "${${program}}" PARENT_SCOPE)
            return()
        else()
            set(brew_package_name pkg-config)
            set(apt_package_name pkg-config)
            set(paths_to_search "/bin" "/usr/bin" "/usr/local/bin")
        endif()
    else()
        message(FATAL "unknown tool ${program} -- unable to acquire.")
    endif()

    if("${program_name}" STREQUAL "")
        message(FATAL_ERROR "Internal error: failed to initialize program_name for program ${program}")
    endif()

    set(full_subdirectory "${DOWNLOADS}/tools/${program_name}/${tool_subdirectory}")
    if(NOT "${tool_subdirectory}" STREQUAL "")
        list(APPEND paths_to_search ${full_subdirectory})
    endif()
    if("${full_subdirectory}" MATCHES [[^(.*)[/\\]+$]])
        # remove trailing slashes, which may turn into a trailing `\` which CMake _does not like_
        set(full_subdirectory "${CMAKE_MATCH_1}")
    endif()

    if("${search_names}" STREQUAL "")
        set(search_names "${program_name}")
    endif()

    z_vcpkg_find_acquire_program_find_internal("${program}"
        INTERPRETER "${interpreter}"
        PATHS ${paths_to_search}
        NAMES ${search_names}
    )
    if(NOT ${program})
        z_vcpkg_find_acquire_program_find_external("${program}"
            ${extra_search_args}
            PROGRAM_NAME "${program_name}"
            MIN_VERSION "${program_version}"
            INTERPRETER "${interpreter}"
            NAMES ${search_names}
            VERSION_COMMAND ${version_command}
        )
    endif()
    if(NOT ${program})
        if(NOT VCPKG_HOST_IS_WINDOWS AND NOT supported_on_unix)
            set(example ".")
            if(NOT "${brew_package_name}" STREQUAL "" AND VCPKG_HOST_IS_OSX)
                set(example ":\n    brew install ${brew_package_name}")
            elseif(NOT "${apt_package_name}" STREQUAL "" AND VCPKG_HOST_IS_LINUX)
                set(example ":\n    sudo apt-get install ${apt_package_name}")
            endif()
            message(FATAL_ERROR "Could not find ${program_name}. Please install it via your package manager${example}")
        endif()

        if(NOT "${sourceforge_args}" STREQUAL "")
            # Locally change editable to suppress re-extraction each time
            set(_VCPKG_EDITABLE 1)
            vcpkg_from_sourceforge(OUT_SOURCE_PATH SFPATH ${sourceforge_args})
            unset(_VCPKG_EDITABLE)
        else()
            vcpkg_download_distfile(archive_path
                URLS ${download_urls}
                SHA512 "${download_sha512}"
                FILENAME "${download_filename}"
            )

            file(MAKE_DIRECTORY "${full_subdirectory}")
            if(raw_executable)
                if(NOT "${rename_binary_to}" STREQUAL "")
                    file(INSTALL "${archive_path}"
                        DESTINATION "${full_subdirectory}"
                        RENAME "${rename_binary_to}"
                        FILE_PERMISSIONS
                            OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE
                    )
                else()
                    file(COPY "${archive_path}"
                        DESTINATION "${full_subdirectory}"
                        FILE_PERMISSIONS
                            OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE
                    )
                endif()
            else()
                cmake_path(GET download_filename EXTENSION archive_extension)
                string(TOLOWER "${archive_extension}" archive_extension)
                if("${archive_extension}" MATCHES [[\.msi$]])
                    cmake_path(NATIVE_PATH archive_path archive_native_path)
                    cmake_path(NATIVE_PATH full_subdirectory destination_native_path)
                    vcpkg_execute_in_download_mode(
                        COMMAND msiexec
                            /a "${archive_native_path}"
                            /qn "TARGETDIR=${destination_native_path}"
                        WORKING_DIRECTORY "${DOWNLOADS}"
                    )
                elseif("${archive_extension}" MATCHES [[\.7z\.exe$]])
                    vcpkg_find_acquire_program(7Z)
                    vcpkg_execute_in_download_mode(
                        COMMAND ${7Z} x
                            "${archive_path}"
                            "-o${full_subdirectory}"
                            -y -bso0 -bsp0
                        WORKING_DIRECTORY "${full_subdirectory}"
                    )
                else()
                    vcpkg_execute_in_download_mode(
                        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
                        WORKING_DIRECTORY "${full_subdirectory}"
                    )
                endif()
            endif()
        endif()

        if(NOT "${post_install_command}" STREQUAL "")
            vcpkg_execute_required_process(
                ALLOW_IN_DOWNLOAD_MODE
                COMMAND ${post_install_command}
                WORKING_DIRECTORY "${full_subdirectory}"
                LOGNAME "${program}-tool-post-install"
            )
        endif()
        unset("${program}")
        unset("${program}" CACHE)
        z_vcpkg_find_acquire_program_find_internal("${program}"
            INTERPRETER "${interpreter}"
            PATHS ${paths_to_search}
            NAMES ${search_names}
        )
        if(NOT ${program})
            message(FATAL_ERROR "Unable to find ${program}")
        endif()
    endif()

    set("${program}" "${${program}}" PARENT_SCOPE)
endfunction()
