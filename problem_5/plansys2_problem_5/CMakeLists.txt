cmake_minimum_required(VERSION 3.5)
project(plansys2_problem_5)


find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(plansys2_msgs REQUIRED)
find_package(plansys2_executor REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(dependencies
    rclcpp
    plansys2_msgs
    plansys2_executor
)

add_executable(deliver_patient_action_node src/deliver_patient_action_node.cpp)
ament_target_dependencies(deliver_patient_action_node ${dependencies})

add_executable(deliver_supply_action_node src/deliver_supply_action_node.cpp)
ament_target_dependencies(deliver_supply_action_node ${dependencies})

add_executable(drop_off_patient_action_node src/drop_off_patient_action_node.cpp)
ament_target_dependencies(drop_off_patient_action_node ${dependencies})

add_executable(fill_box_action_node src/fill_box_action_node.cpp)
ament_target_dependencies(fill_box_action_node ${dependencies})

add_executable(load_first_box_action_node src/load_first_box_action_node.cpp)
ament_target_dependencies(load_first_box_action_node ${dependencies})

add_executable(load_second_box_action_node src/load_second_box_action_node.cpp)
ament_target_dependencies(load_second_box_action_node ${dependencies})

add_executable(load_third_box_action_node src/load_third_box_action_node.cpp)
ament_target_dependencies(load_third_box_action_node ${dependencies})

add_executable(move_carrier_one_box_action_node src/move_carrier_one_box_action_node.cpp)
ament_target_dependencies(move_carrier_one_box_action_node ${dependencies})

add_executable(move_carrier_three_box_action_node src/move_carrier_three_box_action_node.cpp)
ament_target_dependencies(move_carrier_three_box_action_node ${dependencies})

add_executable(move_carrier_two_box_action_node src/move_carrier_two_box_action_node.cpp)
ament_target_dependencies(move_carrier_two_box_action_node ${dependencies})

add_executable(move_empty_carrier_action_node src/move_empty_carrier_action_node.cpp)
ament_target_dependencies(move_empty_carrier_action_node ${dependencies})

add_executable(move_empty_robot_patient_action_node src/move_empty_robot_patient_action_node.cpp)
ament_target_dependencies(move_empty_robot_patient_action_node ${dependencies})

add_executable(move_robot_with_patient_action_node src/move_robot_with_patient_action_node.cpp)
ament_target_dependencies(move_robot_with_patient_action_node ${dependencies})

add_executable(pick_up_patient_action_node src/pick_up_patient_action_node.cpp)
ament_target_dependencies(pick_up_patient_action_node ${dependencies})

add_executable(unload_from_three_action_node src/unload_from_three_action_node.cpp)
ament_target_dependencies(unload_from_three_action_node ${dependencies})

add_executable(unload_one_box_action_node src/unload_one_box_action_node.cpp)
ament_target_dependencies(unload_one_box_action_node ${dependencies})

add_executable(unload_two_box_action_node src/unload_two_box_action_node.cpp)
ament_target_dependencies(unload_two_box_action_node ${dependencies})



install(DIRECTORY launch pddl DESTINATION share/${PROJECT_NAME})

install(TARGETS
  deliver_patient_action_node
  deliver_supply_action_node
  drop_off_patient_action_node
  fill_box_action_node
  load_first_box_action_node
  load_second_box_action_node
  load_third_box_action_node
  move_carrier_one_box_action_node
  move_carrier_three_box_action_node
  move_carrier_two_box_action_node
  move_empty_carrier_action_node
  move_empty_robot_patient_action_node
  move_robot_with_patient_action_node
  pick_up_patient_action_node
  unload_from_three_action_node
  unload_one_box_action_node
  unload_two_box_action_node

  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  find_package(ament_cmake_gtest REQUIRED)
endif()

ament_export_dependencies(${dependencies})

ament_package()