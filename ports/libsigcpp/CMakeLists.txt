cmake_minimum_required(VERSION 3.0)
project(libsigc++)

set(CMAKE_CXX_STANDARD 17)

set(SIGCPP_API_VERSION 2.0)

add_definitions(-DSIGC_BUILD)

include_directories(./MSVC_Net2013) # config file for windows is there
include_directories(.)

set(SICGPP_SOURCES
    sigc++/connection.cc
    sigc++/signal_base.cc
    sigc++/trackable.cc
    sigc++/adaptors/lambda/lambda.cc
    sigc++/functors/slot_base.cc)

add_library(sigc ${SICGPP_SOURCES})
set_target_properties(sigc PROPERTIES OUTPUT_NAME sigc-${SIGCPP_API_VERSION})
install(TARGETS sigc RUNTIME DESTINATION bin ARCHIVE DESTINATION lib)

if(NOT SIGCPP_SKIP_HEADERS)
    install(FILES MSVC_Net2013/sigc++config.h DESTINATION include)
    install(FILES sigc++/sigc++.h DESTINATION include/sigc++)
    install(FILES sigc++/bind.h DESTINATION include/sigc++)
    install(FILES sigc++/bind_return.h DESTINATION include/sigc++)
    install(FILES sigc++/connection.h DESTINATION include/sigc++)
    install(FILES sigc++/limit_reference.h DESTINATION include/sigc++)
    install(FILES sigc++/reference_wrapper.h DESTINATION include/sigc++)
    install(FILES sigc++/retype_return.h DESTINATION include/sigc++)
    install(FILES sigc++/signal.h DESTINATION include/sigc++)
    install(FILES sigc++/signal_base.h DESTINATION include/sigc++)
    install(FILES sigc++/slot.h DESTINATION include/sigc++)
    install(FILES sigc++/trackable.h DESTINATION include/sigc++)
    install(FILES sigc++/type_traits.h DESTINATION include/sigc++)
    install(FILES sigc++/visit_each.h DESTINATION include/sigc++)
    install(FILES sigc++/adaptors/adaptors.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/adaptor_trait.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/bind.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/bind_return.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/bound_argument.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/compose.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/deduce_result_type.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/exception_catch.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/hide.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/retype.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/retype_return.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/track_obj.h DESTINATION include/sigc++/adaptors)
    install(FILES sigc++/adaptors/lambda/base.h DESTINATION include/sigc++/adaptors/lambda)
    install(FILES sigc++/adaptors/lambda/select.h DESTINATION include/sigc++/adaptors/lambda)
    install(FILES sigc++/functors/functors.h DESTINATION include/sigc++/functors)
    install(FILES sigc++/functors/functor_trait.h DESTINATION include/sigc++/functors)
    install(FILES sigc++/functors/mem_fun.h DESTINATION include/sigc++/functors)
    install(FILES sigc++/functors/ptr_fun.h DESTINATION include/sigc++/functors)
    install(FILES sigc++/functors/slot.h DESTINATION include/sigc++/functors)
    install(FILES sigc++/functors/slot_base.h DESTINATION include/sigc++/functors)
endif()

set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/lib)
set(includedir ${CMAKE_INSTALL_PREFIX}/include)
set(SIGCXX_API_VERSION "2.0")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/sigc++.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/sigc++.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sigc++.pc" DESTINATION lib/pkgconfig)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sigc++.pc" DESTINATION lib/pkgconfig RENAME sigc++-2.0.pc)
