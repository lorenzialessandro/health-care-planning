source /opt/ros/humble/setup.bash
colcon build --symlink-install
rosdep install --from-paths ./ --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
ros2 launch plansys2_problem_5 plansys2_problem_5_launch.py