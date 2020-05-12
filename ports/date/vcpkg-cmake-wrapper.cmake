_find_package(${ARGS})

if(NOT TARGET unofficial::date::date AND TARGET date::date)
  add_library(unofficial::date::date INTERFACE IMPORTED)
  target_link_libraries(unofficial::date::date INTERFACE date::date)
endif()

if(NOT TARGET unofficial::date::tz AND TARGET date::tz)
  add_library(unofficial::date::tz INTERFACE IMPORTED)
  target_link_libraries(unofficial::date::tz INTERFACE date::tz)
endif()
