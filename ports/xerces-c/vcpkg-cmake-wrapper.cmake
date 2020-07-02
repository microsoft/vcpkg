_find_package(${ARGS})

if (APPLE)
   if (TARGET XercesC::XercesC)
      set_property(TARGET XercesC::XercesC APPEND PROPERTY INTERFACE_LINK_LIBRARIES  "-framework CoreServices" "-framework CoreFoundation" curl)  
      list(APPEND XercesC_LIBRARIES "-framework CoreServices" "-framework CoreFoundation" curl)
   endif()
endif()
