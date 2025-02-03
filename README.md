# Health Care Planning

This repository contains multiple PDDL planning problems organized in separate folders, each addressing different healthcare planning scenarios.

## Project Structure

```
health-care-planning/
├── problem_1/
│   ├── domain.pddl
│   └── p1.pddl
├── problem_2/
│   ├── domain.pddl
│   └── p1.pddl
├── problem_3/
│   ├── domain.hddl
│   └── p1.hddl
├── problem_4/
│   ├── domain.pddl
│   └── p1.pddl
└── problem_5/
    └── plansys2_problem_5/
```

## Problem Execution Instructions

### Problem 1
Navigate to the problem directory:
```bash
cd problem_1
```
Execute using LAMA planner:
```bash
downward --alias lama domain.pddl p1.pddl
```

### Problem 2
Navigate to the problem directory:
```bash
cd problem_2
```
Execute using LAMA planner:
```bash
downward --alias lama domain.pddl p1.pddl
```

### Problem 3
Navigate to the problem directory:
```bash
cd problem_3
```
Execute using OPTIC planner:
```bash
optic -N domain.pddl p1.pddl
```

### Problem 4
Navigate to the problem directory:
```bash
cd problem_4
```
Execute using PANDA planner:
```bash
java -jar PANDA.jar -parser hddl domain.hddl problem.hddl
```

### Problem 5 (ROS2-based)
This problem requires two terminals for execution.

#### Terminal 1
```bash
# Navigate to the problem directory
cd problem_5/plansys2_problem_5/

# Source ROS2
source /opt/ros/humble/setup.bash

# Install dependencies
rosdep install --from-paths ./ --ignore-src -r -y

# Build the workspace
colcon build --symlink-install

# Source the built workspace
source install/setup.bash

# Launch the planning system
ros2 launch plansys2_problem_5 plansys2_problem_5_launch.py
```

Alternatively, you can directly lunch the [terminal1.sh](/problem_5/plansys2_problem_5/terminal1.sh) inside the problem directory, that run these instructions via:
```bash
./terminal1.sh
```


#### Terminal 2
```bash
# Navigate to the problem directory
cd problem_5/plansys2_problem_5/

# Source ROS2
source /opt/ros/humble/setup.bash

# Source the built workspace
source install/setup.bash

# Launch the planner terminal
ros2 run plansys2_terminal plansys2_terminal

# Source the commands
source /mnt/d/health-care-planning/problem_5/plansys2_problem_5/launch/commands

# Generate and execute the plan
get plan
run
```

