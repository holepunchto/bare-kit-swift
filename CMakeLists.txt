cmake_minimum_required(VERSION 4.0)

find_package(cmake-bare REQUIRED PATHS node_modules/cmake-bare)
find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)

project(bare_kit_swift C)

fetch_package("github:holepunchto/bare-kit#v3" SOURCE_DIR bare_kit)

add_library(bare_kit_framework SHARED)

set_target_properties(
  bare_kit_framework
  PROPERTIES
  FRAMEWORK TRUE
  OUTPUT_NAME BareKit

  MACOSX_FRAMEWORK_BUNDLE_NAME "BareKit"
  MACOSX_FRAMEWORK_IDENTIFIER "to.holepunch.bare.kit"
  MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
  MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
)

if(IOS)
  set_target_properties(
    bare_kit_framework
    PROPERTIES
    MACOSX_FRAMEWORK_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/lib/iOS.plist"
  )
else()
  set_target_properties(
    bare_kit_framework
    PROPERTIES
    MACOSX_FRAMEWORK_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/lib/macOS.plist"
  )
endif()

target_link_libraries(
  bare_kit_framework
  PRIVATE
    bare_kit
)

bare_target(target)

install(TARGETS bare_kit_framework FRAMEWORK DESTINATION ${target})

install(FILES "${bare_kit}/include/bare-kit.h" DESTINATION ${target}/BareKit.framework/Headers)
