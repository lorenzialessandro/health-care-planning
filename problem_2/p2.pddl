(define (problem p2-health-care-2)
    (:domain health-care-2)
    (:objects
        box1 box2 box3 box4 - box
        robot-box1 robot-box2 - robot-box
        robot-patient1 - robot-patient
        
        central_warehouse entrance
        area1 area2 area3 emergency_area
        corridor1 corridor2
        - location
        
        MedicalUnit1 MedicalUnit2a MedicalUnit2b MedicalUnit3 EmergencyUnit - medical-unit
        scalpel aspirine tongue bandage antibiotic tank - content
        patient1 patient2 patient3 patient4 - patient

        capacity0 capacity1 capacity2 capacity3 capacity4 - capacity-num
        carrier1 carrier2 - carrier
    )

    (:init
        ; Locations
        (connected central_warehouse corridor1)
        (connected corridor1 central_warehouse)
        (connected corridor1 area1)
        (connected area1 corridor1)
        (connected area1 area2)
        (connected area2 area1)
        (connected corridor1 area3)
        (connected area3 corridor1)
        (connected corridor2 corridor1)
        (connected corridor1 corridor2)
        (connected corridor2 emergency_area)
        (connected entrance corridor2)
        (connected corridor2 entrance)

        ; Initial positions
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        (at box3 central_warehouse)
        (at box4 central_warehouse)

        (content-available scalpel central_warehouse)
        (content-available aspirine central_warehouse)
        (content-available tongue central_warehouse)
        (content-available bandage central_warehouse)
        (content-available antibiotic central_warehouse)
        (content-available tank central_warehouse)

        (at MedicalUnit1 area1)
        (at MedicalUnit2a area2)
        (at MedicalUnit2b area2)
        (at MedicalUnit3 area3)
        (at EmergencyUnit emergency_area)

        (at robot-box1 central_warehouse)
        (at robot-box2 central_warehouse)

        (at robot-patient1 entrance)

        (at patient1 entrance)
        (at patient2 entrance)
        (at patient3 corridor1)
        (at patient4 corridor2)
        
        ; Initial states
        (empty box1)
        (empty box2)
        (empty box3)
        (empty box4)
        
        ; Carriers 
        (next-capacity capacity0 capacity1)
        (next-capacity capacity1 capacity2)
        (next-capacity capacity2 capacity3)
        (next-capacity capacity3 capacity4)

        ; carrier1 can carry 3 boxes and is empty
        (carrier-has-capacity carrier1 capacity4) 
        (carrier-current-capacity carrier1 capacity0) 
        ; carrier2 can carry 2 box and has 1 box
        (carrier-has-capacity carrier2 capacity3) 
        (carrier-current-capacity carrier2 capacity1)

        (robot-has-carrier robot-box1 carrier1)
        (robot-has-carrier robot-box2 carrier2)    

        ; Units needs
        (unit-needs-content MedicalUnit1 scalpel)
        (unit-needs-content MedicalUnit1 aspirine)
        (unit-needs-content MedicalUnit2a antibiotic)
        (unit-needs-content MedicalUnit2b tank)
        (unit-needs-content MedicalUnit3 tongue)
        (unit-needs-content EmergencyUnit bandage)
        
        ; Patients needs
        (patient-needs-unit patient1 MedicalUnit1)
        (patient-needs-unit patient2 MedicalUnit2b)
        (patient-needs-unit patient3 MedicalUnit3)
        (patient-needs-unit patient4 EmergencyUnit)
    )

    (:goal
        (and
            (unit-has-content MedicalUnit1 scalpel)
            (unit-has-content MedicalUnit1 aspirine)
            (unit-has-content MedicalUnit2a antibiotic)
            (unit-has-content MedicalUnit2b tank)
            (unit-has-content MedicalUnit3 tongue)
            (unit-has-content EmergencyUnit bandage)
            
            (patient-at-unit patient1 MedicalUnit1)
            (patient-at-unit patient2 MedicalUnit2b)
            (patient-at-unit patient3 MedicalUnit3)
            (patient-at-unit patient4 EmergencyUnit)
        )
    )
)