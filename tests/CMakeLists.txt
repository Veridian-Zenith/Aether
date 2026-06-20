add_executable(run_tests test_runner.cpp)
target_link_libraries(run_tests PRIVATE aether_lib)
target_compile_definitions(run_tests PRIVATE BUILD_TESTING=1)
add_test(NAME AetherTests COMMAND run_tests)
