(define (problem p1-health-care-basic)
    (:domain health-care-basic)
    (:objects
        box1 box2 - box
        robot-box1 - robot-box
        robot-patient1 - robot-patient
        warehouse area1 area2 corridor1 - location
        unit1 unit2 - medical-unit
        bandage aspirine scalpel - content
        patient1 patient2 - patient
    )

    (:init
        ; Locations
        (connected warehouse corridor1)
        (connected corridor1 warehouse)
        (connected corridor1 area1)
        (connected area1 corridor1)
        (connected corridor1 area2)
        (connected area2 corridor1)

        (is-central_warehouse warehouse)
        
        ; Initial positions
        (at box1 warehouse)
        (at box2 warehouse)
        
        (at robot-box1 warehouse)
        (at robot-patient1 warehouse)
        
        (at unit1 area1)
        (at unit2 area2)

        (at patient1 corridor1)
        (at patient2 area1)
        
        ; Initial states
        (empty box1)
        (empty box2)
        
        (content-available bandage warehouse)
        (content-available aspirine warehouse)
        (content-available scalpel warehouse)
        
        (unit-needs-content unit1 bandage)
        (unit-needs-content unit1 aspirine)
        (unit-needs-content unit2 scalpel)

        (patient-needs-unit patient1 unit1)
        (patient-needs-unit patient2 unit2)
    
    )

    (:goal
        (and
            (unit-has-content unit1 bandage)
            (unit-has-content unit1 aspirine)
            (unit-has-content unit2 scalpel)

            (patient-at-unit patient1 unit1)
            (patient-at-unit patient2 unit2)
        )
    )
)