# Health Care Planning
This repository contains the implementation for the *Automated Planning Theory and Practice* course assignment (AY 2024-2025) at University of Trento. 

![](img.png)

The objective of the assignment is to model and solve planning problems in a **healthcare scenario** using `PDDL` (Planning Domain Definition Language) and `HDDL` (Hierarchical Domain Definition Language), as well as to integrate a temporal planning model within a robotic framework leveraging the `PlanSys2` infrastructure in ROS2. 

The assignment focuses on developing and testing planning models with increasing complexity:
- **Problem 1**: Modeling a base `PDDL` domain for task execution.
- **Problem 2**: Extending the base `PDDL` domain with more complex tasks.
- **Problem 3**: Structuring tasks using Hierarchical Task Networks (HTN).
- **Problem 4**: Introducing temporal planning with durative actions and
concurrency constraints.
- **Problem 5**: Executing the temporal model in `PlanSys2`.

More details, explanations and output examples are present in the **[report.pdf](report.pdf)** file.

## Project Structure
Each folder in the repo contains the `PDDL`/`HDDL` domain and problem files, along with the corresponding `PlanSys2` implementation for the last task. 

## Quick Start
```bash
# Clone the repository
git https://github.com/lorenzialessandro/health-care-planning
cd health-care-planning

# Run a simple example (Problem 1) - See instructions below
cd problem_1
fast-downward.py domain.pddl p2_simple.pddl --search "astar(lmcut())"
```

## Project Structure
```
health-care-planning/
├── problem_1/            # Base PDDL implementation
│   ├── domain.pddl
│   ├── p*.pddl      # Problem instances
│   └── p*.plan      # Output plans instances
├── problem_2/           # Extended PDDL domain
├── problem_3/           # HTN implementation
├── problem_4/           # Temporal planning
└── problem_5/           # PlanSys2 integration
    └── plansys2_problem_5/
```


## Installation and Setup
### Prerequisites
To run this project, ensure you have the following installed:
- **ROS2 Humble**: Required for `PlanSys2`
- **Python 3.8+** (for scripting and running planners)
- **Java (JDK 11+)** (for PANDA planner in Problem 3)
- **Planning tools:**
  - [Fast Downward](https://www.fast-downward.org/)
  - [LAMA](https://github.com/rock-planning/planning-lama)
  - [OPTIC](https://github.com/dbanda/optic/)
  - [POPF](https://github.com/fmrico/popf)
  - [PANDA](https://panda-planner-dev.github.io/)
  
### Setting Up ROS2 and PlanSys2
#### Installing Dependencies
```bash
sudo apt update && sudo apt install -y ros-humble-plansys2
rosdep install --from-paths ./ --ignore-src -r -y
```
#### Building the Workspace
```bash
colcon build --symlink-install
source install/setup.bash
```

## Problem 1
The first domain established a solid foundation by coordinating robots for single-box deliveries and patient transport.

To evaluate the **[domain.pddl](/problem_1/domain.pddl)**, different problems of increasing complexity can be tested:
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


Similar to the previous problem, various settings and goals are tested to evaluate the **[domain.pddl](/problem_2/domain.pddl)** conformity, this time incorporating the new `carrier` type with distinct capacities to assess the robot’s ability to handle multiple boxes simultaneously.
- [p1.pddl](/problem_2/p1.pddl): same as the previous one, but introduces two types of box-robots (and carriers), one with a maximum capacity of 3 boxes and the other with a maximum capacity of 2 boxes.
- [p2_simple.pddl](/problem_2/p2_simple.pddl): variant of the one in the previous domain, modified to include the carrier with a 3-box capacity.


### Running 
Navigate to the problem directory:
```bash
cd problem_2
```

Problems can be executed using `LAMA-first`, `Fast Downward` or `LAMA`, following previous instructions. 

## Problem 3
The third scenario is modeled using **Hierarchical Task Networks (HTN)**. All actions and predicates remain the same as in Problem 2, but new abstract tasks have been introduced, along with their corresponding methods.

The tested problem **[p1.hddl](/problem_3/p1.hddl)** is inspired by the main problem from the previous scenarios and involves delivering three supplies and accompanying two patients.

### Running 
Navigate to the problem directory:
```bash
cd problem_3
```
Problems can be executed using `PANDA` framework *(Planning and Acting in a Network Decomposition Architecture)*:

```bash
java -jar PANDA.jar -parser hddl domain.hddl p1.hddl
```


## Problem 4
This problem introduces the **durative actions** extension, where time and temporal constraints must be considered. The goal is to add a duration for each action from Problem 2 and integrate time constraints to prevent certain operations from being executed in parallel. 

The new **[domain.pddl](/problem_4/domain.pddl)** can be tested with:

- [p1.pddl](/problem_4/p1.pddl): complex scenario with the goal of delivering four supplies and accompanying three patients, utilizing two box-carrying robots and one patient transport robot
- [p2_simple.pddl](problem_4/p2_simple.pddl) as in Problem 2, featuring two delivery tasks and two patient transport tasks.

### Running 
Navigate to the problem directory:
```bash
cd problem_4
```
Problems can be executed using `OPTIC` or `POPF`:
```bash
optic domain.pddl p1.pddl 
```

```bash
popf domain.pddl p1.pddl
```


## Problem 5
The final problem involves the execution of the Problem 4 scenario in **`PlanSys2`**.


The **[domain.pddl](/problem_5/plansys2_problem_5/pddl/domain.pddl)** used is the same in Problem 4.
The injected knowledge mimics the `p1.pddl` scenario from the previous problem and is represented in file `commands` ([here](problem_5/plansys2_problem_5/launch/commands)).


Once the plan is run, the `ROS2` terminal visualizes the corresponding execution, showing that all tasks are performed as expected. 

### Running

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

Alternatively, you can directly launch the [terminal1.sh](/problem_5/plansys2_problem_5/terminal1.sh) inside the problem directory, that run these instructions via:
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

# Generate the plan
get plan

# Execute the plan
run
```

The last instruction produces the visualization of the plan execution in Terminal 1. 

## Troubleshooting & Debugging
### Common Issues
1. **Planner not found**
   - Ensure the planner is installed and accessible from the terminal.
   - Example: `export PATH=$PATH:/path/to/fast-downward`

2. **ROS2 package errors**
   - Ensure ROS2 environment is sourced before running commands: `source /opt/ros/humble/setup.bash`

3. **Plan execution fails in PlanSys2**
   - Check if the knowledge base is correctly injected (`commands` file in Problem 5).

### Runtime Issues
- **Plan Generation Timeout**: Increase search time limit
- **Memory Errors**: Reduce problem complexity or increase swap space
- **PlanSys2 Connection Issues**: Check ROS2 network configuration

## Author
Alessandro Lorenzi - alessandro.lorenzi-1@studenti.unitn.it

