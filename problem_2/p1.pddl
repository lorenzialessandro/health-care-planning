(define (problem p1)
    (:domain health-care-2)
    (:objects
        box1 box2 box3 - box
        carrier1 carrier2 - carrier ; carriers are not defined in the domain
        robot-box1 robot-box2 - robot-box
        robot-patient1 - robot-patient
        
        central_warehouse entrance
        area1 area2
        corridor1
        - location
        
        MedicalUnit1 MedicalUnit2 - medical-unit
        scalpel scissor aspirine - content
        patient1 patient2 - patient
    )

    (:init
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        (at box3 central_warehouse)

        (content-available scalpel central_warehouse)
        (content-available scissor central_warehouse)

        (at robot-box1 central_warehouse)
        (at robot-box2 central_warehouse)
        (at robot-patient1 entrance)

        (at MedicalUnit1 area1)
        (at MedicalUnit2 area2)
        
        (empty box1)
        (empty box2)

        (at patient1 corridor1)
        (at patient2 entrance)

        ; road map
        (connected central_warehouse area1)
        (connected central_warehouse area2)
        (connected entrance corridor1)
        (connected corridor1 area1)
        (connected corridor1 area2)

        ; unit needs content
        (unit-needs-content MedicalUnit1 scalpel)
        (unit-needs-content MedicalUnit2 scissor)
        ; patient needs accompaniment
        (patient-needs-unit patient2 MedicalUnit2)
        (patient-needs-unit patient1 MedicalUnit1)

        ; robot has carrier
        (robot-has-carrier robot-box1 carrier1)
        (robot-has-carrier robot-box2 carrier2)
        ; define carrier capacity
        (= (carrier-capacity carrier1) 1)
        (= (carrier-capacity carrier2) 2)

    )

    (:goal
        (and
            (unit-has-content MedicalUnit1 scalpel)
            (unit-has-content MedicalUnit2 scissor)
            (unit-has-content MedicalUnit2 aspirine)

            (patient-at-unit patient2 MedicalUnit2)
            (patient-at-unit patient1 MedicalUnit1)
        )
    )
)