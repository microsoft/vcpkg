if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ACE_wrappers/ace)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.dre.vanderbilt.edu/previous_versions/ACE-6.5.1.zip"
    FILENAME "ACE-6.5.1.zip"
    SHA512 b6444b183a356f4a9fc4af57ccc239a400121fbb00547ff9d13c51f0fc20f38b0aa87b9568531472e5f7fde82deea3d4c3d91d7504aca89799a2505ba492c73a
)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# Add ace/config.h file
# see http://www.dre.vanderbilt.edu/~schmidt/DOC_ROOT/ACE/ACE-INSTALL.html#win32
file(WRITE ${SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"")
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ace_vc14.sln
    PLATFORM ${MSBUILD_PLATFORM}
)

# ACE itself does not define an install target, so it is not clear which
# headers are public and which not. For the moment we install everything
# that is in the source path and ends in .h, .inl
function(install_ace_headers_subdirectory SOURCE_PATH RELATIVE_PATH)
    file(GLOB HEADER_FILES ${SOURCE_PATH}/${RELATIVE_PATH}/*.h ${SOURCE_PATH}/${RELATIVE_PATH}/*.inl)
    file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/${RELATIVE_PATH})
endfunction()

# We manually install header found in the ace directory because in that case
# we are supposed to install also *cpp files, see ACE_wrappers\debian\libace-dev.install file
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h ${SOURCE_PATH}/*.inl ${SOURCE_PATH}/*.cpp)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/)

# Install headers in subdirectory
install_ace_headers_subdirectory(${SOURCE_PATH} "Compression")
install_ace_headers_subdirectory(${SOURCE_PATH} "Compression/rle")
install_ace_headers_subdirectory(${SOURCE_PATH} "ETCL")
install_ace_headers_subdirectory(${SOURCE_PATH} "Monitor_Control")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/arpa")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/net")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/netinet")
install_ace_headers_subdirectory(${SOURCE_PATH} "os_include/sys")

# Install the libraries
function(install_ace_library SOURCE_PATH ACE_LIBRARY)
    set(LIB_PATH ${SOURCE_PATH}/../lib/)
    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}d.dll
        ${LIB_PATH}/${ACE_LIBRARY}d_dll.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )

    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}.dll
        ${LIB_PATH}/${ACE_LIBRARY}.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}d.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )

    file(INSTALL
        ${LIB_PATH}/${ACE_LIBRARY}.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endfunction()

install_ace_library(${SOURCE_PATH} "ACE")
install_ace_library(${SOURCE_PATH} "ACE_Compression")
install_ace_library(${SOURCE_PATH} "ACE_ETCL")
install_ace_library(${SOURCE_PATH} "ACE_Monitor_Control")
install_ace_library(${SOURCE_PATH} "ACE_QoS")
install_ace_library(${SOURCE_PATH} "ACE_RLECompression")

# Handle copyright
file(COPY ${SOURCE_PATH}/../COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ace)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/ace/copyright)
