(define (domain healthcare_basic)
    (:requirements :strips :typing)
    (:types
        medical_unit box supply robot patient - locatable
        robot_box robot_patient - robot
        location - object
    )

    (:predicates
        ; Location predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
        
        ; Box predicates
        (box_loaded_in_robot ?b - box ?r - robot_box)
        (box_unloaded ?b - box)
        (empty ?b - box)
        (box_has_supply ?b - box ?s - supply)
        
        ; Unit predicates
        (unit_needs_supply ?u - medical_unit ?s - supply)
        (unit_has_supply ?u - medical_unit ?s - supply)
        

        ; Patient predicates
        (patient_unloaded ?p - patient)
        (patient_loaded_in_robot ?p - patient ?r - robot_patient)
        (patient_needs_unit ?p - patient ?u - medical_unit)
        (patient_at_unit ?p - patient ?u - medical_unit)

        ; Robot predicates
        (robot_patient_empty ?r - robot_patient)
        (robot_box_empty ?r - robot_box)
    )
    
    ; === Supply operations ===

    ; Fill box with supply
    ; box is empty and unloaded and box, content and robot are at the same location
    (:action fill_box
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (at ?s ?l)
            (box_unloaded ?b)
            (empty ?b)
        )
        :effect (and 
            (not (empty ?b))
            (box_has_supply ?b ?s)
        )
    )

    ; Deliver supply to unit
    ; causing the unit to have the supply and not need it anymore, and the box to be empty
    (:action deliver_supply
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply ?u - medical_unit)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (at ?u ?l)
            (box_has_supply ?b ?s)
            (box_unloaded ?b)
            (unit_needs_supply ?u ?s)           ; unit needs the supply
        )
        :effect (and
            (not (box_has_supply ?b ?s))
            (empty ?b)                          ; box is empty
            (not (unit_needs_supply ?u ?s))
            (unit_has_supply ?u ?s)             ; unit has the supply
        )
    )

    ; Load box 
    ; causing the box to be loaded in the robot and the robot to not be empty
    (:action load_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (box_unloaded ?b)                   ; box is unloaded
            (robot_box_empty ?r)                ; robot is empty
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_robot ?b ?r)         ; box is loaded in the robot
            (not (robot_box_empty ?r))
        )
    )

    ; Unload box
    ; causing the box to be unloaded and the robot to be empty
    (:action unload_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (box_loaded_in_robot ?b ?r)
        )
        :effect (and 
            (box_unloaded ?b)                   ; box is unloaded  
            (not (box_loaded_in_robot ?b ?r))
            (robot_box_empty ?r)                ; robot is empty
            (at ?b ?l)
         )
    )

    ; Movement Boxes

    ; Move empty robot
    ; causing the update of the robot location
    (:action move_empty_robot_box
        :parameters (?r - robot_box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)                 ; check if the locations are connected
            (robot_box_empty ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)                         ; robot is at the new location   
        )
    )

    ; Move robot with box
    ; causing the update of both the box and the robot location
    (:action move_robot_with_box
        :parameters (?r - robot_box ?b - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
            (box_loaded_in_robot ?b ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?b ?l1))
            (at ?r ?l2)                         ; robot is at the new location
            (at ?b ?l2)                         ; box is at the new location
        )
    )

    ; === Patient operations ===

    ; Pick up patient
    ; causing the patient to be loaded in the robot and the robot to not be empty
    (:action pick_up_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (patient_unloaded ?p)               ; patient is unloaded
            (robot_patient_empty ?r)            ; robot is empty
        )
        :effect (and 
            (not (patient_unloaded ?p))
            (patient_loaded_in_robot ?p ?r)     ; patient is loaded in the robot
            (not (robot_patient_empty ?r))
        )
    )

    ; Drop off patient
    ; causing the patient to be unloaded and the robot to be empty 
    (:action drop_off_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (patient_loaded_in_robot ?p ?r)         ; patient is loaded in the robot
        )
        :effect (and 
            (patient_unloaded ?p)                   ; patient is unloaded
            (not (patient_loaded_in_robot ?p ?r))
            (robot_patient_empty ?r)                ; robot is empty
            (at ?p ?l)
         )
    )

    ; Deliver patient to unit
    ; causing the patient to be at the unit and not need it anymore
    (:action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (at ?u ?l)

            (patient_unloaded ?p)
            (patient_needs_unit ?p ?u)          ; patient needs the unit
        )
        :effect (and
            (not (patient_needs_unit ?p ?u))
            (patient_at_unit ?p ?u)             ; patient is at the unit
        )
    )


    ; Movement Patients
    
    
    ; Move empty robot
    ; causing the update of the robot location
    (:action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)             ; check if the locations are connected
            (robot_patient_empty ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)                     ; robot is at the new location
        )
    )

    ; Move robot with patient
    ; causing the update of both the patient and the robot location
    (:action move_robot_with_patient
        :parameters (?r - robot_patient ?p - patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
            (patient_loaded_in_robot ?p ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?p ?l1))
            (at ?r ?l2)                 ; robot is at the new location
            (at ?p ?l2)                 ; patient is at the new location
        )
    )
)