include(CmakeFindDependencyMacro)
find_dependency(Iconv)

set(Intl_FOUND TRUE)
set(Intl_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../include")
set(Intl_INCLUDE_DIRS ${Intl_INCLUDE_DIR} ${Iconv_INCLUDE_DIRS})
set(Intl_LIBRARY @Intl_LIBRARY@)
set(Intl_LIBRARIES ${Intl_LIBRARY} ${Iconv_LIBRARIES})
