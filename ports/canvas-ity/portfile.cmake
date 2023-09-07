#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO a-e-k/canvas_ity
    REF f32fbb37e2fe7c0fcaee6ebdc02d3e5385603fd5
    SHA512 37111c445ce36705f43ebd9c5acd68fc7dd1ddaf9ffd1b857a936ff7c0f861fdad26ad5af5c841f72898f561447e5efeb70814e928b961ecb68ac6ae39cae5b9
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/canvas_ity.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(READ "${SOURCE_PATH}/src/canvas_ity.hpp" CANVAS_ITY_CODE)
if(NOT CANVAS_ITY_CODE MATCHES "ISC license")
    message(FATAL_ERROR "Please check license for this port")
endif()
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")
