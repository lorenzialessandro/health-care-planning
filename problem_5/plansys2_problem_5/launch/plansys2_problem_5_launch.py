# Copyright 2019 Intelligent Robotics Lab
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    # Get the launch directory
    example_dir = get_package_share_directory('plansys2_problem_5')
    namespace = LaunchConfiguration('namespace')

    declare_namespace_cmd = DeclareLaunchArgument(
        'namespace',
        default_value='',
        description='Namespace')

    plansys2_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('plansys2_bringup'),
            'launch',
            'plansys2_bringup_launch_monolithic.py')),
        launch_arguments={
          'model_file': example_dir + '/pddl/domain.pddl',
          'namespace': namespace
          }.items())

    # Specify the actions
    deliver_patient_cmd = Node(
        package='plansys2_problem_5',
        executable='deliver_patient_action_node',
        name='deliver_patient_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    deliver_supply_cmd = Node(
        package='plansys2_problem_5',
        executable='deliver_supply_action_node',
        name='deliver_supply_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    drop_off_patient_cmd = Node(
        package='plansys2_problem_5',
        executable='drop_off_patient_action_node',
        name='drop_off_patient_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    fill_box_cmd = Node(
        package='plansys2_problem_5',
        executable='fill_box_action_node',
        name='fill_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    load_first_box_cmd = Node(
        package='plansys2_problem_5',
        executable='load_first_box_action_node',
        name='load_first_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    load_second_box_cmd = Node(
        package='plansys2_problem_5',
        executable='load_second_box_action_node',
        name='load_second_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    load_third_box_cmd = Node(
        package='plansys2_problem_5',
        executable='load_third_box_action_node',
        name='load_third_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_carrier_one_box_cmd = Node(
        package='plansys2_problem_5',
        executable='move_carrier_one_box_action_node',
        name='move_carrier_one_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_carrier_three_box_cmd = Node(
        package='plansys2_problem_5',
        executable='move_carrier_three_box_action_node',
        name='move_carrier_three_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_carrier_two_box_cmd = Node(
        package='plansys2_problem_5',
        executable='move_carrier_two_box_action_node',
        name='move_carrier_two_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_empty_carrier_cmd = Node(
        package='plansys2_problem_5',
        executable='move_empty_carrier_action_node',
        name='move_empty_carrier_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_empty_robot_patient_cmd = Node(
        package='plansys2_problem_5',
        executable='move_empty_robot_patient_action_node',
        name='move_empty_robot_patient_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_robot_with_patient_cmd = Node(
        package='plansys2_problem_5',
        executable='move_robot_with_patient_action_node',
        name='move_robot_with_patient_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    pick_up_patient_cmd = Node(
        package='plansys2_problem_5',
        executable='pick_up_patient_action_node',
        name='pick_up_patient_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    unload_from_three_cmd = Node(
        package='plansys2_problem_5',
        executable='unload_from_three_action_node',
        name='unload_from_three_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    unload_one_box_cmd = Node(
        package='plansys2_problem_5',
        executable='unload_one_box_action_node',
        name='unload_one_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    unload_two_box_cmd = Node(
        package='plansys2_problem_5',
        executable='unload_two_box_action_node',
        name='unload_two_box_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    
        

    
    # Create the launch description and populate
    ld = LaunchDescription()

    ld.add_action(declare_namespace_cmd)

    # Declare the launch options
    ld.add_action(plansys2_cmd)

    # Add any actions
    ld.add_action(deliver_patient_cmd)
    ld.add_action(deliver_supply_cmd)
    ld.add_action(drop_off_patient_cmd)
    ld.add_action(fill_box_cmd)
    ld.add_action(load_first_box_cmd)
    ld.add_action(load_second_box_cmd)
    ld.add_action(load_third_box_cmd)
    ld.add_action(move_carrier_one_box_cmd)
    ld.add_action(move_carrier_three_box_cmd)
    ld.add_action(move_carrier_two_box_cmd)
    ld.add_action(move_empty_carrier_cmd)
    ld.add_action(move_empty_robot_patient_cmd)
    ld.add_action(move_robot_with_patient_cmd)
    ld.add_action(pick_up_patient_cmd)
    ld.add_action(unload_from_three_cmd)
    ld.add_action(unload_one_box_cmd)
    ld.add_action(unload_two_box_cmd)
    
    
    return ld
