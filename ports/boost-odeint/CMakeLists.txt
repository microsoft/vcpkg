cmake_minimum_required(VERSION 3.8...3.20)

project(boost_numeric_odeint VERSION "${BOOST_SUPERPROJECT_VERSION}" LANGUAGES CXX)

add_library(boost_numeric_odeint INTERFACE)
add_library(Boost::numeric_odeint ALIAS boost_numeric_odeint)

target_include_directories(boost_numeric_odeint INTERFACE include)

target_link_libraries(boost_numeric_odeint
  INTERFACE
    Boost::array
    Boost::assert
    Boost::bind
    Boost::compute
    Boost::config
    Boost::core
    Boost::function
    Boost::fusion
    Boost::iterator
    Boost::math
    Boost::mpl
    Boost::multi_array
    Boost::preprocessor
    Boost::range
    Boost::static_assert
    Boost::throw_exception
    Boost::type_traits
    Boost::numeric_ublas
    Boost::units
    Boost::utility
)

if(BUILD_TESTING AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test/CMakeLists.txt")

  add_subdirectory(test)

endif()
