cmake_minimum_required(VERSION 3.17)
project(lv2 NONE)

add_library(lv2 INTERFACE)

install(
    TARGETS lv2
    EXPORT lv2-config
    INCLUDES DESTINATION include
)

install(
    DIRECTORY lv2
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)
install(FILES lv2/core/lv2.h DESTINATION include)

# Install headers to old URI-style paths, using mapping from wscript
file(READ wscript WSCRIPT)
string(REGEX MATCHALL "'[^']+' *: *'lv2/[^']+'" SPEC_MAP "${WSCRIPT}")
foreach(PAIR ${SPEC_MAP})
    string(REGEX MATCH "'([^']+)' *: *'([^']+)'" _ "${PAIR}")
    install(
        DIRECTORY "lv2/${CMAKE_MATCH_1}/"
        DESTINATION "include/${CMAKE_MATCH_2}"
        FILES_MATCHING PATTERN "*.h"
    )
endforeach()

install(
    EXPORT lv2-config
    NAMESPACE lv2::
    DESTINATION share/lv2
)
