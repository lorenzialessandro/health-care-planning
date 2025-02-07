# Health Care Planning
This repo contains the code for the assignment of the *Automated Planning Theory and Practice* course (AY 2024-2025). 

The objective of the assignment is to model and solve planning problems in a **healthcare scenario** using `PDDL` (Planning Domain Definition Language) and `HDDL` (Hierarchical Domain Definition Language), as well as to integrate a temporal planning model within a robotic framework leveraging the `PlanSys2` infrastructure in ROS2. 

The assignment focuses on developing and testing planning models with increasing complexity:
1. Modeling a base `PDDL` domain for task execution.
2. Extending the base `PDDL` domain with more complex tasks.
3. Structuring tasks using Hierarchical Task Networks (HTN).
4. Introducing temporal planning with durative actions and
concurrency constraints.
5. Executing the temporal model in `PlanSys2`.

Each folder in the repo contains the `PDDL`/`HDDL` domain and problem files, along with the corresponding `PlanSys2` implementation for the last task. 

## Project Structure

```
TODO
```

## Problem 1
The first domain established a solid foundation by coordinating robots for single-box deliveries and patient transport.

To comprehensively evaluate the **[domain.pddl](/problem_1/domain.pddl)**, different problems of increasing complexity can be tested:
- [p1.pddl](/problem_1/p1.pddl): The most complex scenario, it features a diversified roadmap, multiple supplies, and several patients.
- [p2_simple.pddl](/problem_2/p2_simple.pddl): A simpler scenario with two supply locations and two patients, where items are positioned in different locations. Only one robot of each type is available.
- [p3_simple_multiple.pddl](/problem_1/p3_simple_multiple.pddl): Similar to [p2_simple.pddl](/problem_2/p2_simple.pddl) but with a total of four robots. 

The folder contains the output plans of all the problems, `p1.pddl` was solved using `LAMA-first`, while the simplest two were solved using `Fast Downward`. 

### Running 
Navigate to the problem directory:
```bash
cd problem_1
```
Problems can be executed using `LAMA-first`, `Fast Downward` or `LAMA`:
```bash
downward --alias lama-first domain.pddl p1.pddl
```

```bash
fast-downward.py domain.pddl p1.pddl --search "astar(lmcut())"
```
```bash
downward --alias lama domain.pddl p1.pddl
```

## Problem 2
In the second and next domains, the carriers are introduced and new actions are implemented for the handling of multiple box operations. 
## Problem 3
The third scenario is modeled using Hierarchical Task Networks (HTN). All actions and predicates remain the same as in Problem 2, but new abstract tasks have been introduced, along with their corresponding methods.
## Problem 4
This problem introduces the durative actions extension, where time and temporal constraints must be considered. The goal is to add a duration for each action from Problem 2 and integrate time constraints to prevent certain operations from being executed in parallel. 
## Problem 5
The final problem involves the execution of the Problem 4 scenario in `PlanSys2`.

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

