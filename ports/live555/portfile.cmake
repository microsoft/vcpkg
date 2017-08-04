include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/live)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.2017.06.04.tar.gz"
    FILENAME "live.2017.06.04.tar.gz"
    SHA512 89eb3854c2ef7d0a1f443b4ca46c66040dfcc586ffd1e3e08c1b9e831eae6ade1c16e628c0ed0e7804c4e7430993f662e3fe8df2f09903024153d188276c3088
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/master.txt  ${CURRENT_BUILDTREES_DIR}/src/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/live.txt  ${CURRENT_BUILDTREES_DIR}/src/live/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/BasicUsageEnvironment.txt  ${CURRENT_BUILDTREES_DIR}/src/live/BasicUsageEnvironment/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/groupsock.txt  ${CURRENT_BUILDTREES_DIR}/src/live/groupsock/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/liveMedia.txt  ${CURRENT_BUILDTREES_DIR}/src/live/liveMedia/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/mediaServer.txt  ${CURRENT_BUILDTREES_DIR}/src/live/mediaServer/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/proxyServer.txt  ${CURRENT_BUILDTREES_DIR}/src/live/proxyServer/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/testProgs.txt  ${CURRENT_BUILDTREES_DIR}/src/live/testProgs/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND}  -E copy ${CMAKE_CURRENT_LIST_DIR}/UsageEnvironment.txt  ${CURRENT_BUILDTREES_DIR}/src/live/UsageEnvironment/CMakeLists.txt WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_cmake()

file(GLOB DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/live/*/Release/*.dll"
)
file(GLOB LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/live/*/Release/*.lib"
)
file(GLOB DEBUG_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/live/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/live/*/Debug/*.lib"

)

file(GLOB HEADERS
"${CURRENT_BUILDTREES_DIR}/src/live/BasicUsageEnvironment/include/*.hh"
"${CURRENT_BUILDTREES_DIR}/src/live/groupsock/include/*.hh"
"${CURRENT_BUILDTREES_DIR}/src/live/liveMedia/include/*.hh"
"${CURRENT_BUILDTREES_DIR}/src/live/UsageEnvironment/include/*.hh"
)
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/live/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/live555 RENAME copyright)

vcpkg_copy_pdbs()
