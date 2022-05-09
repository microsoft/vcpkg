set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest_contents)
string(JSON version GET "${manifest_contents}" version)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(name LLVM-${version}-win32.exe)
            set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${name}")
            set(hash 82bebd0c0912fd000602f5961492ada913e3b6cb63001b63e2de3e070a168c65a628ebb1a443403b272210af131240f3a3032e03478037b5a8200cc243f27b74)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(name LLVM-${version}-win64.exe)
            set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${name}")
            set(hash 96916ef4838e2b43debbf6e92c3b3b1a862051348771df9de6c7c1b0d839ef04c057bddde7e59c2f08e1483d7609dd7a5e77616ed1072047404caa974841a668)
        endif()
        vcpkg_download_distfile(archive_path
            URLS "${url}"
            FILENAME "${name}" 
            SHA512 "${hash}"
        )
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
        vcpkg_execute_in_download_mode(
                                COMMAND "${7Z}" x "${archive_path}" "-o${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}" "-y" "-bso0" "-bsp0"
                                WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
                            )
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/$PLUGINSDIR")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
        file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") # binary distribution does not contain a license
    endif()
endif()
