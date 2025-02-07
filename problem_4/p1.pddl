(define (problem healthcare_durative_p1)
    (:domain healthcare_durative)
    
    (:objects
        entrance central_warehouse
        main_corridor secondary_corridor
        emergency_area surgical_area 
        - location
        
        robot_box_1 robot_box_2 - robot_box
        carrier1 carrier2 - carrier
        
        robot_patient_1 - robot_patient
        
        box1 box2 box3 box4 - box
        
        scalpel aspirine tongue bandage antibiotic tank anesthesia - supply

        trauma_unit triage_unit operation_unit - medical_unit
        
        patient1 patient2 patient3 - patient
    )
    
    (:init
        ; Location connections 
        (connected entrance main_corridor)
        (connected main_corridor entrance)
        (connected main_corridor emergency_area)
        (connected emergency_area main_corridor)
        (connected main_corridor surgical_area)
        (connected surgical_area main_corridor)
        (connected main_corridor secondary_corridor)
        (connected secondary_corridor main_corridor)
        (connected secondary_corridor central_warehouse)
        (connected central_warehouse secondary_corridor)
        
        ; Initial locations
        (at robot_box_1 central_warehouse)  ; robotic agent allowed to carry boxes is located at the central_warehouse to deliver boxes
        (at robot_box_2 central_warehouse)  ; robotic agent allowed to carry boxes is located at the central_warehouse to deliver boxes
        (at carrier1 central_warehouse)     ; carrier1 is located at the central warehouse
        (at carrier2 central_warehouse)     ; carrier2 is located at the central warehouse
        (at robot_patient_1 entrance)       ; single robotic agent allowed to accompany patients is initially located at the entrance
        ; Box locations: all boxes are located at a single location : central_warehouse
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        (at box3 central_warehouse)
        (at box4 central_warehouse)
        ; Supplies location: all supplies are located at a single location : central_warehouse
        (at scalpel central_warehouse)
        (at aspirine central_warehouse)
        (at tongue central_warehouse)
        (at bandage central_warehouse)
        (at antibiotic central_warehouse)
        (at tank central_warehouse)
        (at anesthesia central_warehouse)

        ; All the patients are at the entrance
        (at patient1 entrance)
        (at patient2 entrance)
        (at patient3 entrance)
        
        ; Medical units locations (no units are located at the central warehouse)
        (at trauma_unit emergency_area)
        (at triage_unit emergency_area)
        (at operation_unit surgical_area)

        ; Initial box states
        (box_unloaded box1)
        (box_unloaded box2)
        (box_unloaded box3)
        (box_unloaded box4)
        (empty box1)
        (empty box2)
        (empty box3)
        (empty box4)

        ; Initial carrier state
        (carrier_empty carrier1)
        (carrier_empty carrier2)
        
        (has_capacity_one carrier1) (has_capacity_two carrier1) (has_capacity_three carrier1)   ; carrier1 has capacity for max 3 boxes
        (has_capacity_one carrier2) (has_capacity_two carrier2)                                 ; carrier2 has capacity for max 2 boxes

        ; Initial robot box states
        ; each robotic agent has a carrier with a maximum load capacity (that might be different from each agent)
        (robot_has_carrier robot_box_1 carrier1)
        (robot_has_carrier robot_box_2 carrier2) 
        (robot_box_not_busy robot_box_1)    ; robot_box_1 is not busy
        (robot_box_not_busy robot_box_2)    ; robot_box_2 is not busy

        ; Initial robot states
        (robot_patient_empty robot_patient_1)   
        (robot_patient_not_busy robot_patient_1)    ; robot_patient_1 is not busy

        ; Initial patient states
        (patient_unloaded patient1)
        (patient_unloaded patient2)
        (patient_unloaded patient3)
        
        ; Supply needs
        (unit_needs_supply trauma_unit scalpel)
        (unit_needs_supply trauma_unit aspirine)
        (unit_needs_supply triage_unit tongue)
        (unit_needs_supply operation_unit antibiotic)
        (unit_needs_supply operation_unit tank)

        ; Patient needs
        (patient_needs_unit patient1 trauma_unit)
        (patient_needs_unit patient2 triage_unit)
        (patient_needs_unit patient3 operation_unit)
    )
    
    (:goal
        (and
            ; All units should have their needed supplies
            (unit_has_supply trauma_unit scalpel)
            (unit_has_supply trauma_unit aspirine)
            (unit_has_supply triage_unit tongue)
            (unit_has_supply operation_unit antibiotic)

            ; All patients should be at the medical unit
            (patient_at_unit patient1 trauma_unit)
            (patient_at_unit patient2 triage_unit)
            (patient_at_unit patient3 operation_unit)
        )
    )

    (:metric minimize (total-time))
)