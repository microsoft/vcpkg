include_guard(GLOBAL)

function(x_vcpkg_get_legacy_cmake_3)
    cmake_parse_arguments(PARSE_ARGV 0 param "SET_CMAKE_COMMAND;PREPEND_ENV_PATH" "OUT_VAR_COMMAND;OUT_VAR_PATH" "")
    if(DEFINED param_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments: `${param_UNPARSED_ARGUMENTS}`")
    endif()

    set(_download_version "3.30.1")
    set(_download_endpoint "https://github.com/Kitware/CMake/releases/download/v${_download_version}")
    set(_basename "")
    set(_sha512 "")

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "x86|x64")
        set(_basename "cmake-${_download_version}-windows-i386")
        set(_extension ".zip")
        set(_sha512 0b74bd4222064cfb6e42838987704eb21d57ad5f7bbd87714ab570f1d107fa19bd2f14316475338518292bc377bf38b581a07c73267a775cd385bbd1800879b4)
    elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(_basename "cmake-${_download_version}-windows-arm64")
        set(_extension ".zip")
        set(_sha512 40bcdeff5ff40044629f49e0effc958a719353330ea39876b919fb7c2d441885c884acf43e644ab5dedcb95503d211c895da1c0b6360e71449bea6a981f8e128)
    elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64|arm64")
        set(_basename "cmake-${_download_version}-macos-universal")
        set(_extension ".tar.gz")
        set(_sha512 71290d3b5e51724711e8784f5b21100cb0cffdbb889da7572a26dd171d9052601496de8d39c42d76ef3a9245af2ab35a590bf53ad68d7bb8a2047b64272d2647)
    elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(_basename "cmake-${_download_version}-linux-x86_64")
        set(_extension ".tar.gz")
        set(_sha512 84ce1333ed696a1736986fba2853c5d8db0e4c9addaf4a4723911248c6d49ecf545adf8bd46091d198fc7bd1e6c896798661463aa1ce3a726a093883aaa19adf)
    elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(_basename "cmake-${_download_version}-linux-aarch64")
        set(_extension ".tar.gz")
        set(_sha512 ec6c1c682dda2381aa5ebef98a2597e4ab6b4563639c28b2f30c20360694b902a7b33c175c796169a9f99ed139f053916042caed58d83298680894c2840dbb87)
    else()
        message(FATAL_ERROR "Target not yet supported by '${PORT}'")
    endif()
    set(_url "${_download_endpoint}/${_basename}${_extension}")
    message(DEBUG "URL: '${_url}'")
    message(DEBUG "SHA512: '${_sha512}'")

    vcpkg_download_distfile(ARCHIVE_PATH
        URLS "${_url}"
        SHA512 "${_sha512}"
        FILENAME "${_basename}${_extension}"
    )

    message(DEBUG "ARCHIVE_PATH: '${ARCHIVE_PATH}'")

    if(EXISTS "${CURRENT_BUILDTREES_DIR}/x-legacy-cmake-3/${_basename}")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/x-legacy-cmake-3/${_basename}")
    endif()

    file(ARCHIVE_EXTRACT
        INPUT "${ARCHIVE_PATH}"
        DESTINATION "${CURRENT_BUILDTREES_DIR}/x-legacy-cmake-3"
    )

    set(_legacy_cmake_3_bin "${CURRENT_BUILDTREES_DIR}/x-legacy-cmake-3/${_basename}/bin")
    set(_legacy_cmake_3_command "${_legacy_cmake_3_bin}/cmake${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(PATH_SEPERATOR ";")
    else()
        set(PATH_SEPERATOR ":")
    endif()

    message(WARNING "Using different CMake in buildtrees: `${_basename}`.")

    if(param_SET_CMAKE_COMMAND)
        set(CMAKE_COMMAND "${_legacy_cmake_3_command}" PARENT_SCOPE)
    endif()
    if(param_PREPEND_ENV_PATH)
        set(ENV{PATH} "${_legacy_cmake_3_bin}${PATH_SEPERATOR}$ENV{PATH}" PARENT_SCOPE)
    endif()
    if(DEFINED param_OUT_VAR_COMMAND)
        set("${param_OUT_VAR_COMMAND}" "${_legacy_cmake_3_command}" PARENT_SCOPE)
    endif()
    if(DEFINED param_OUT_VAR_PATH)
        set("${param_OUT_VAR_PATH}" "${_legacy_cmake_3_bin}" PARENT_SCOPE)
    endif()
endfunction()
