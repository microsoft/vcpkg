# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RandyGaul/cute_headers
    REF 4f765abf4a59660e72f9f49c444371ba373e834b
    SHA512 e898520dc668ce9d1f51c748da1c674f9fa0540bac7a0d10a45fde5ebb0ca6573dc5178ce41199a138e3153343b1ff0c589bc7908a8edcd4a7753d5a1440030b
    HEAD_REF master
)

file(GLOB CUTE_HEADERS_FILES ${SOURCE_PATH}/*.h)
file(COPY ${CUTE_HEADERS_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(STRINGS "${SOURCE_PATH}/cute_math2d.h" SOURCE_LINES)
list(REVERSE SOURCE_LINES)

set(line_no 0)
foreach(line ${SOURCE_LINES})
    math(EXPR line_no "${line_no} + 1")
    if(line STREQUAL "/*")
        break()
    endif()
endforeach()

list(SUBLIST SOURCE_LINES 0 ${line_no} SOURCE_LINES)
list(REVERSE SOURCE_LINES)
list(JOIN SOURCE_LINES "\n" _contents)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}")
