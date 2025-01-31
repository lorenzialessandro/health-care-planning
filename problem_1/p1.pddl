(define (problem healthcare_basic_p1)
    (:domain healthcare_basic)
    
    (:objects
        warehouse corridor1 corridor2 area1 - location
        robot1 - robot_box
        robot2 - robot_patient
        box1 box2 box3 - box
        bandages medicine masks - supply
        patient1 - patient
        unit1 - medical_unit
    )
    
    (:init
        ; Location connections 
        (connected warehouse corridor1)
        (connected corridor1 warehouse)
        (connected corridor1 corridor2)
        (connected corridor2 corridor1)
        (connected corridor2 area1)
        (connected area1 corridor2)
        
        ; Initial locations
        (at robot1 warehouse)
        (at robot2 warehouse)
        (at box1 warehouse)
        (at box2 warehouse)
        (at box3 warehouse)
        (at patient1 warehouse)
        
        ; Medical units locations
        (at unit1 area1)

        ; Supplies location
        (at bandages warehouse)
        (at medicine warehouse)
        (at masks warehouse)
        
        ; Initial box states
        (box_unloaded box1)
        (box_unloaded box2)
        (box_unloaded box3)
        (empty box1)
        (empty box2)
        (empty box3)

        ; Initial robot states
        (robot_patient_empty robot2)
        (robot_box_empty robot1)

        ; Initial patient states
        (patient_unloaded patient1)
        
        ; Supply needs
        (unit_needs_supply unit1 bandages)
        (unit_needs_supply unit1 medicine)
        (unit_needs_supply unit1 masks)

        ; Patient needs
        (patient_needs_unit patient1 unit1)
    )
    
    (:goal
        (and
            ; All units should have their needed supplies
            (unit_has_supply unit1 bandages)
            (unit_has_supply unit1 medicine)
            (unit_has_supply unit1 masks)

            ; All patients should be at the medical unit
            (patient_at_unit patient1 unit1)
            
            ; Final state requirements
            (at robot1 warehouse)
            (at robot2 warehouse)
            (robot_box_empty robot1)
            (robot_patient_empty robot2)
        )
    )
)