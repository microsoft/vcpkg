
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre-targets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre16-targets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre32-targets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcrecpp-targets.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcreposix-targets.cmake")

set(PCRE_INCLUDE_DIR ${CMAKE_CURRENT_LIST_FILE}/../../include)
set(PCRE_LIBRARY unofficial::pcre::pcre)
set(PCRE16_LIBRARY unofficial::pcre::pcre16)
set(PCRE32_LIBRARY unofficial::pcre::pcre32)
set(PCRECPP_LIBRARY unofficial::pcre::pcre unofficial::pcre::pcrecpp)
set(PCREPOSIX_LIBRARY unofficial::pcre::pcreposix unofficial::pcre::pcre)

set(PCRE_INCLUDE_DIRS ${PCRE_INCLUDE_DIR})
set(PCRE_LIBRARIES ${PCRE_LIBRARY})
set(PCRE16_LIBRARIES ${PCRE16_LIBRARY})
set(PCRE32_LIBRARIES ${PCRE32_LIBRARY})
set(PCRECPP_LIBRARIES ${PCRECPP_LIBRARY})
set(PCREPOSIX_LIBRARIES ${PCREPOSIX_LIBRARY})



