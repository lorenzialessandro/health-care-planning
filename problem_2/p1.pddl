(define (problem p1-health-care)
    (:domain health-care)
    (:objects
        box1 box2  - box
        robot-box1 - robot-box
        robot-patient1 - robot-patient
        central_warehouse area1 area2 corridor1 - location
        unit1 unit2 - medical-unit
        bandage aspirine scalpel - content
        patient1 patient2 - patient

        capacity0 capacity1 capacity2 capacity3 capacity4 - capacity-num
        carrier1 - carrier
    )

    (:init
        ; Locations
        (connected central_warehouse corridor1)
        (connected corridor1 central_warehouse)
        (connected corridor1 area1)
        (connected area1 corridor1)
        (connected corridor1 area2)
        (connected area2 corridor1)

        (is-central_warehouse central_warehouse)
        
        ; Initial positions
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        
        (at robot-box1 central_warehouse)
        (at robot-patient1 central_warehouse)
        
        (at unit1 area1)
        (at unit2 area2)

        (at patient1 corridor1)
        (at patient2 area1)
        
        ; Initial states
        (empty box1)
        (empty box2)
        
        (content-available bandage central_warehouse)
        (content-available aspirine central_warehouse)
        (content-available scalpel central_warehouse)

        ; Carriers 
        (next-capacity capacity0 capacity1)
        (next-capacity capacity1 capacity2)
        (next-capacity capacity2 capacity3)
        (next-capacity capacity3 capacity4)

        ; carrier1 can carry 2 boxes and start with 0 boxes
            ; NOTE: capacity3 represents the MAXIMUM capacity value, not the number of boxes. 
            ; The carrier can only load boxes until reaching capacity3:
                ; capacity0 → capacity1 (1 box)
                ; capacity1 → capacity2 (2 boxes)
        (carrier-has-capacity carrier1 capacity3) ; max 2 boxes in carrier1
        (carrier-current-capacity carrier1 capacity0) ; start with 0 boxes 
        
        (robot-has-carrier robot-box1 carrier1) ; robot-box1 has carrier1

        ; Needs
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