(define (problem p3-health-care-1)
    (:domain health-care-1)
    ;; same problem as p2, but with multiple robots:
    ; theare 3 box-robots and 2 patient-robots
    (:objects
        box1 box2 box3 - box
        robot-box1 robot-box2 robot-box3 - robot-box
        robot-patient1 robot-patient2 - robot-patient

        central_warehouse entrance area1 area2 area3 emergency_area corridor1 corridor2 - location

        MedicalUnit1 MedicalUnit2a MedicalUnit2b MedicalUnit3 EmergencyUnit - medical-unit
        scalpel aspirine tongue bandage antibiotic tank - content
        patient1 patient2 patient3 patient4 - patient
    )

    (:init
        ; all boxes are located at central_warehouse
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        (at box3 central_warehouse)
        ; all contents are located at central_warehouse
        (content-available scalpel central_warehouse)
        (content-available aspirine central_warehouse)
        (content-available tongue central_warehouse)
        (content-available bandage central_warehouse)
        (content-available antibiotic central_warehouse)
        (content-available tank central_warehouse)
        ; medical units (not located at central_warehouse)
        (at MedicalUnit1 area1)
        (at MedicalUnit2a area2)
        (at MedicalUnit2b area2)
        (at MedicalUnit3 area3)
        (at EmergencyUnit emergency_area)
        ; 3 robot-box located at central_warehouse
        (at robot-box1 central_warehouse)
        (at robot-box2 central_warehouse)
        (at robot-box3 central_warehouse)
        ; 2 robot-patient located at entrance
        (at robot-patient1 entrance)
        (at robot-patient2 entrance)

        (empty box1)
        (empty box2)
        (empty box3)
        (box-free box1)
        (box-free box2)
        (box-free box3)

        (at patient1 entrance)
        (at patient2 entrance)
        (at patient3 corridor1)
        (at patient4 corridor2)
        (patient-free patient1)
        (patient-free patient2)
        (patient-free patient3)
        (patient-free patient4)

        ; road map
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

        ; unit needs content
        (unit-needs-content MedicalUnit1 scalpel)
        (unit-needs-content MedicalUnit1 aspirine)
        (unit-needs-content MedicalUnit2a antibiotic)
        (unit-needs-content MedicalUnit2b tank)
        (unit-needs-content MedicalUnit3 tongue)
        (unit-needs-content EmergencyUnit bandage)

        ; patient needs accompaniment
        (patient-needs-unit patient1 MedicalUnit1)
        (patient-needs-unit patient2 MedicalUnit2b)
        (patient-needs-unit patient3 MedicalUnit3)
        (patient-needs-unit patient4 EmergencyUnit)

        ; robot can carry and accompany
        (robot-can-carry robot-box1)
        (robot-can-carry robot-box2)
        (robot-can-carry robot-box3)
        (robot-can-accompany robot-patient1)
        (robot-can-accompany robot-patient2)
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