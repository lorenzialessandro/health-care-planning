(define (problem p3)
    (:domain health-care-1)
    (:objects
        robot-patient1 - robot-patient
        
        entrance
        area1 area2
        corridor1
        - location
        
        MedicalUnit1 MedicalUnit2 - medical-unit
        patient1 - patient
    )

    (:init
        ; medical units (not located at central_warehouse)
        (at MedicalUnit1 area1)
        (at MedicalUnit2 area2)

        ; single robot-patient located at entrance
        (at robot-patient1 entrance)
  
        (at patient1 area1)

        ; road map
        (connected entrance corridor1)
        (connected corridor1 area1)
        (connected corridor1 area2)
        
        ; patient needs accompaniment
        (patient-needs-unit patient1 MedicalUnit2)
    )

    (:goal
        (and
            (patient-at-unit patient1 MedicalUnit2)
        )
    )
)