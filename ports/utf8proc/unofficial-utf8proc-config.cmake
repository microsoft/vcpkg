message(WARNING "find_package(unofficial-utf8proc) is deprecated.
utf8proc provides CMake targets:

  find_package(utf8proc)
  target_link_libraries(main PRIVATE utf8proc::utf8proc)
")
include(CMakeFindDependencyMacro)
find_dependency(utf8proc CONFIG)
if(NOT TARGET utf8proc)
    add_library(utf8proc ALIAS utf8proc::utf8proc)
endif()
