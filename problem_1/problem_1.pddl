(define (problem healthcare-delivery-1)
    (:domain healthcare)
    
    (:objects
        ;; Locations
        central_warehouse entrance unit1 unit2 corridor1 corridor2 - location
        
        ;; Units
        medical-unit1 medical-unit2 medical-unit3 - unit
        
        ;; Robots
        box-robot - robot-delivery
        patient-robot - robot-patient
        
        ;; Boxes
        box1 box2 - box
        
        ;; Contents
        scalpel aspirine tongue-depressor - content
        
        ;; Patients
        patient1 patient2 - patient
    )
    
    (:init
        ;; Location connections (Roadmap)
        (connected central_warehouse corridor1)
        (connected corridor1 unit1)
        (connected corridor1 unit2)
        (connected entrance corridor2)
        (connected corridor1 corridor2)
        (connected corridor2 corridor1)
        
        
        ;; Initial locations
        ; Initially all boxes are located at a single location that we may call the central_warehouse.
        (at box1 central_warehouse)
        (at box2 central_warehouse)
        ; All the contents to load in the boxes are initially located at the central_warehouse.
        (at scalpel central_warehouse)
        (at aspirine central_warehouse)
        (at tongue-depressor central_warehouse)
        ; There are no medical unit at the central_warehouse.
        (at medical-unit1 unit1)
        (at medical-unit2 unit2)
        (at medical-unit3 unit2)
        ; A single robotic agent allowed to carry boxes is located at the central_warehouse to deliver boxes.
        (at box-robot central_warehouse)
        ; A single robotic agent allowed to accompany patients is initially located at the entrance.
        (at patient-robot entrance)
        
        ;; Initial box states
        (empty box1)
        (empty box2)
        ;; Initial patient states
        (at patient1 corridor2)
        (at patient2 entrance)

        (need-accompaniment patient1)
        (need-accompaniment patient2)
    )
    
    (:goal 
        (and 
            ;; Specific content delivery goals
            (unit-has-content medical-unit1 scalpel)
            (unit-has-content medical-unit2 tongue-depressor)
            (unit-has-content medical-unit1 aspirine)
            (unit-has-content medical-unit2 aspirine)
            (unit-has-content medical-unit3 aspirine)
            
            ;; Patient delivery goals
            (patient-at-unit patient1 medical-unit1) 
            (patient-at-unit patient2 medical-unit2)
            (patient-at-unit patient1 medical-unit2)
        )
    )
)