# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static libraries not supported; building dynamic instead")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()
if (VCPKG_CRT_LINKAGE STREQUAL "static")
    message(STATUS "Static linking against the CRT not supported; building dynamic instead")
    set(VCPKG_CRT_LINKAGE "dynamic")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF Xerces-C_3_2_2
    SHA512 66f60fe9194376ac0ca99d13ea5bce23ada86e0261dde30686c21ceb5499e754dab8eb0a98adadd83522bda62709377715501f6dac49763e3a686f9171cc63ea
    HEAD_REF trunk
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(CMAKE_HOST_WIN32)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CURRENT_PACKAGES_DIR}/cmake"
        "${CURRENT_PACKAGES_DIR}/share/xerces-c/cmake")
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CURRENT_PACKAGES_DIR}/debug/cmake"
        "${CURRENT_PACKAGES_DIR}/share/xerces-c/cmake")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/cmake"
        "${CURRENT_PACKAGES_DIR}/debug/cmake"
    )
    file(GLOB release_exe "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    file(GLOB debug_exe "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(REMOVE ${release_exe} ${debug_exe})
else()
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CURRENT_PACKAGES_DIR}/lib/cmake/XercesC"
        "${CURRENT_PACKAGES_DIR}/share/xerces-c/cmake")
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/XercesC"
        "${CURRENT_PACKAGES_DIR}/share/xerces-c/cmake")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/lib/cmake"
        "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()
