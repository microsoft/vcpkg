vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
if(buildtrees_path_length GREATER 35 AND CMAKE_HOST_WIN32)
    vcpkg_buildpath_length_warning(35)
    message(WARNING "The ${PORT} source was will be extracted to ${CURRENT_BUILDTREES_DIR} , which has more then 35 characters in length.")
    message(FATAL_ERROR "terminating due to ${CURRENT_BUILDTREES_DIR} being too long.")
endif()
#set(VCPKG_BUILD_TYPE release) #You probably want to set this to reduce build type and space requirements
message(STATUS "${PORT} requires a lot of free disk space (>100GB), ram (>8 GB) and time (>2h per configuration) to be successfully build.\n\
-- As such ${PORT} is currently experimental.\n\
-- If ${PORT} fails post build validation please try manually reducing VCPKG_MAX_CONCURRENCY and open up an issue if it still cannot build. \n\
-- If it fails due to post validation the successfully installed files can be found in ${CURRENT_PACKAGES_DIR} \n\
-- and just need to be copied into ${CURRENT_INSTALLED_DIR}")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "If ${PORT} directly fails ${PORT} might require additional prerequisites on Linux and OSX. Please check the configure logs.\n")
endif()
include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(NINJA)
vcpkg_find_acquire_program(PERL)
set(NODEJS "${CURRENT_HOST_INSTALLED_DIR}/tools/node/node${VCPKG_HOST_EXECUTABLE_SUFFIX}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
get_filename_component(NINJA_DIR "${NINJA}" DIRECTORY )
get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
get_filename_component(PERL_DIR "${PERL}" DIRECTORY )

if(CMAKE_HOST_WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    set(CMAKE_CXX_STANDARD 17)
endif()

vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")
vcpkg_add_to_path(PREPEND "${GPERF_DIR}")
vcpkg_add_to_path(PREPEND "${NINJA_DIR}")
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")
vcpkg_add_to_path(PREPEND "${PERL_DIR}")

vcpkg_execute_in_download_mode(
    COMMAND "${NINJA}" --version
    OUTPUT_VARIABLE ninja_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
)
if(ninja_version VERSION_GREATER_EQUAL "1.12.1")
    message(WARNING
        "Found ninja version ${ninja_version} which may fail to build ${PORT}."
        "You can supply a different filepath using per-port customization of CMake variable NINJA."
    )
endif()

function(download_distfile var url sha512)
    string(REGEX REPLACE ".*/" "" filename "${url}")
    vcpkg_download_distfile(archive
        URLS "${url}"
        FILENAME "${filename}"
        SHA512 "${sha512}"
    )
    set("${var}" "${archive}" PARENT_SCOPE)
endfunction()

download_distfile(html5lib
    "https://files.pythonhosted.org/packages/6c/dd/a834df6482147d48e225a49515aabc28974ad5a4ca3215c18a882565b028/html5lib-1.1-py2.py3-none-any.whl"
    53e828155e489176e8ea0cdc941ec6271764bbf7069b1a83c0ce8adb26694450d17d7c76b4a00a14dbb99ca203ae02b3d8c8e41953fd59499bbc8a8d4900975b
)
download_distfile(six
    "https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl"
    2796b93aaac73193faeb5c93a85d23c2ae9fc4a7e57df88dc34b704a36fa62cd0b1fb5d1a74b961a23eff2467be94eb14f5f10874dfa733dc4ab59715280bbf3
)
download_distfile(webencodings
    "https://files.pythonhosted.org/packages/f4/24/2a3e3df732393fed8b3ebf2ec078f05546de641fe1b667ee316ec1dcf3b7/webencodings-0.5.1-py2.py3-none-any.whl"
    2a34dbebc33a44a3691216104982b4a978a2a60b38881fc3704d04cb1da38ea2878b5ffec5ac19ac43f50d00c8d4165e05fdf6fa4363a564d8c5090411fc392d
)
x_vcpkg_get_python_packages(
    OUT_PYTHON_VAR PYTHON3
    PYTHON_VERSION 3
    PACKAGES --no-index "${html5lib}" "${six}" "${webencodings}"
)
get_filename_component(PYTHON_DIR "${PYTHON3}" DIRECTORY )
vcpkg_add_to_path(APPEND "${PYTHON_DIR}")

set(PATCHES
    common.pri.patch
    gl.patch
    build_1.patch
    workaround-protobuf-issue.patch
    0001-Fix-jumbo-build-error-due-to-ResolveColor-redefiniti.patch
    fix-spellcheck-buildflags.patch
    python3_update.patch
    win_python3.patch
    macos_tahoe.patch
    crc32c_applesilicon_aes.patch
    clang17_update.patch
    win_cpp17_core.patch
)

set(OPTIONS "-webengine-python-version" "python3")
if("proprietary-codecs" IN_LIST FEATURES)
    list(APPEND OPTIONS "-webengine-proprietary-codecs")
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_IS_OSX)
        list(APPEND OPTIONS "-system-webengine-webp" "-system-webengine-icu")
    endif()
    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{C_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{CPLUS_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
endif()

qt_submodule_installation(PATCHES ${PATCHES} BUILD_OPTIONS ${OPTIONS})
