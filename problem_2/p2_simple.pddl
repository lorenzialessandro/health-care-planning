(define (problem healthcare_p2_simple) 
    (:domain healthcare)
    (:objects
        entrance central_warehouse
        main_corridor
        emergency_area surgical_area 
        - location
        
        robot_box_1 - robot_box
        carrier1 - carrier
        
        robot_patient_1 - robot_patient
        
        box1 box2 - box
        
        scalpel aspirine - supply

        trauma_unit triage_unit operation_unit - medical_unit
        
        patient1 patient2 - patient
    )
    
    (:init
        ; Location connections 
        (connected central_warehouse main_corridor)
        (connected main_corridor central_warehouse)
        (connected entrance main_corridor)
        (connected main_corridor entrance)
        (connected main_corridor emergency_area)
        (connected emergency_area main_corridor)
        (connected main_corridor surgical_area)
        (connected surgical_area main_corridor)

        ; Initial locations
        (at robot_box_1 central_warehouse) ; single robotic agent allowed to carry boxes is located at the central_warehouse to deliver boxes
        (at carrier1 central_warehouse) ; carrier1 is located at the central warehouse
        (at robot_patient_1 entrance) ; single robotic agent allowed to accompany patients is initially located at the entrance
        ; Box locations: all boxes are located at a single location : central_warehouse
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        ; Supplies location: all supplies are located at a single location : central_warehouse
        (at scalpel central_warehouse)
        (at aspirine central_warehouse)

        ; All the patients are at the entrance
        (at patient1 entrance)
        (at patient2 entrance)
        
        ; Medical units locations (no units are located at the central warehouse)
        (at trauma_unit emergency_area)
        (at triage_unit emergency_area)
        (at operation_unit surgical_area)

        ; Initial box states
        (box_unloaded box1)
        (box_unloaded box2)
        (empty box1)
        (empty box2)

        ; Initial carrier states
        (carrier_empty carrier1)
        (has_capacity_one carrier1) (has_capacity_two carrier1) (has_capacity_three carrier1)   ; carrier1 has capacity for max 3 boxes

        ; Initial robot box states
        (robot_has_carrier robot_box_1 carrier1)
        
        ; Initial robot states
        (robot_patient_empty robot_patient_1)

        ; Initial patient states
        (patient_unloaded patient1)
        (patient_unloaded patient2)
        
        ; Supply needs
        (unit_needs_supply trauma_unit scalpel)
        (unit_needs_supply operation_unit aspirine)

        ; Patient needs
        (patient_needs_unit patient1 trauma_unit)
        (patient_needs_unit patient2 triage_unit)
    )
    
    (:goal
        (and
            ; All units should have their needed supplies
            (unit_has_supply trauma_unit scalpel)
            (unit_has_supply operation_unit aspirine)

            ; All patients should be at the medical unit
            (patient_at_unit patient1 trauma_unit)
            (patient_at_unit patient2 triage_unit)
        )
    )

    ; (:metric minimize (total-cost))
)