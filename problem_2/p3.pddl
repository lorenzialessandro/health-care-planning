(define (problem p3-health-care)
    (:domain health-care)
    (:objects
        box1 box2 - box
        robot-box - robot-box
        central_warehouse area - location
        unit - medical-unit
        aspirine scalpel - content

        capacity0 capacity1 capacity2 capacity3 - capacity-num
        carrier - carrier
    )

    (:init
        ; Locations
        (connected central_warehouse area)
        (connected area central_warehouse)

        (is-central_warehouse central_warehouse)
        
        ; Initial positions
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        
        (at robot-box central_warehouse)
        
        (at unit area)
        
        ; Initial states
        (empty box1)
        (empty box2)
        
        (content-available aspirine central_warehouse)
        (content-available scalpel central_warehouse)

        ; Carriers 
        (next-capacity capacity0 capacity1)
        (next-capacity capacity1 capacity2)
        (next-capacity capacity2 capacity3)

        ; carrier can load max 2 boxes and starts empty
        (carrier-has-capacity carrier capacity3) 
        (carrier-current-capacity carrier capacity0)  
        
        (robot-has-carrier robot-box carrier) 

        ; Needs
        (unit-needs-content unit aspirine)
        (unit-needs-content unit scalpel)
    )

    (:goal
        (and
            (unit-has-content unit aspirine)
            (unit-has-content unit scalpel)
        )
    )
)