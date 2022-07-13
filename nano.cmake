function(nano_add_module NAME)
  include(FetchContent)
  FetchContent_Declare(
    nano-${NAME}
    GIT_REPOSITORY "https://github.com/Meta-Sonic/nano-${NAME}.git"
    GIT_TAG master
  )

  FetchContent_MakeAvailable(nano-${NAME})
endfunction()

function(nano_clang_format NAME SOURCES)
  find_program(CLANG_FORMAT clang-format REQUIRED)
  add_custom_target(${NAME}-formatting DEPENDS ${SOURCES})
  add_custom_command(TARGET ${NAME}-formatting PRE_BUILD
      COMMAND "${CLANG_FORMAT}" --Werror  --dry-run ${SOURCES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  add_dependencies(${NAME} ${NAME}-formatting)
  set_target_properties(${NAME}-formatting PROPERTIES XCODE_GENERATE_SCHEME OFF)
endfunction()

function(nano_create_module NAME)
    set(options OPTIONAL DEV BUILD_TESTS)
    set(oneValueArgs "")
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(OPT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    set(MODULE_NAME nano-${NAME})

    add_library(${MODULE_NAME} INTERFACE ${OPT_SOURCES})
    source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${OPT_SOURCES})
    target_include_directories(${MODULE_NAME} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

    add_library(nano::${NAME} ALIAS ${MODULE_NAME})

    set_target_properties(${MODULE_NAME} PROPERTIES XCODE_GENERATE_SCHEME OFF)

    if (OPT_DEV)
        set(OPT_BUILD_TESTS ON)
        nano_clang_format(${MODULE_NAME} ${OPT_SOURCES})
    endif()

    if (OPT_BUILD_TESTS)
        nano_add_module(nano-test)

        file(GLOB_RECURSE TEST_SOURCE_FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.h")

        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/tests" FILES ${TEST_SOURCE_FILES})

        set(TEST_NAME nano-${NAME}-tests)
        add_executable(${TEST_NAME} ${TEST_SOURCE_FILES})
        target_include_directories(${TEST_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/tests")
        target_link_libraries(${TEST_NAME} PUBLIC nano::test ${MODULE_NAME})

        set(CLANG_OPTIONS -Weverything -Wno-c++98-compat)
        set(MSVC_OPTIONS /W4)

        target_compile_options(${TEST_NAME} PUBLIC
            "$<$<CXX_COMPILER_ID:Clang,AppleClang>:${CLANG_OPTIONS}>"
            "$<$<CXX_COMPILER_ID:MSVC>:${MSVC_OPTIONS}>")

        # set_target_properties(${TEST_NAME} PROPERTIES CXX_STANDARD 20)
    endif()
endfunction()