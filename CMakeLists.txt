cmake_minimum_required(VERSION 4.0)

find_package(cmake-bare REQUIRED PATHS node_modules/cmake-bare)
find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)

project(bare_kit_swift C)

set(BARE_KIT_SWIFT_ENGINE "v8" CACHE STRING "The JavaScript engine to build Bare Kit with, either v8 or javascriptcore")

if(BARE_KIT_SWIFT_ENGINE STREQUAL "javascriptcore")
  set(BARE_ENGINE "github:holepunchto/libjsc#255ffb1")
elseif(NOT BARE_KIT_SWIFT_ENGINE STREQUAL "v8")
  message(FATAL_ERROR "Unknown engine '${BARE_KIT_SWIFT_ENGINE}'")
endif()

fetch_package("github:holepunchto/bare-kit@3.2.1" SOURCE_DIR bare_kit)

get_target_property(framework bare_kit::shared ALIASED_TARGET)

get_directory_property(version DIRECTORY "${bare_kit}" DEFINITION bare_kit_VERSION)

if(IOS)
  set(plist "${CMAKE_CURRENT_LIST_DIR}/lib/iOS.plist")
else()
  set(plist "${CMAKE_CURRENT_LIST_DIR}/lib/macOS.plist")
endif()

set_target_properties(
  ${framework}
  PROPERTIES
  FRAMEWORK TRUE
  OUTPUT_NAME BareKit

  MACOSX_FRAMEWORK_INFO_PLIST "${plist}"
  MACOSX_FRAMEWORK_BUNDLE_NAME "BareKit"
  MACOSX_FRAMEWORK_IDENTIFIER "to.holepunch.bare.kit"
  MACOSX_FRAMEWORK_BUNDLE_VERSION "${version}"
  MACOSX_FRAMEWORK_SHORT_VERSION_STRING "${version}"
)

add_custom_target(bare_kit_swift ALL)

add_dependencies(bare_kit_swift bare_kit::shared)

bare_target(target)

install(TARGETS ${framework} FRAMEWORK DESTINATION ${target})

install(FILES "${bare_kit}/include/bare-kit.h" DESTINATION ${target}/BareKit.framework/Headers)

if(IOS)
  set(resources ${target}/BareKit.framework)
else()
  set(resources ${target}/BareKit.framework/Versions/A/Resources)
endif()

install(
  FILES "${CMAKE_CURRENT_LIST_DIR}/lib/${BARE_KIT_SWIFT_ENGINE}.xcprivacy"
  DESTINATION ${resources}
  RENAME PrivacyInfo.xcprivacy
)
