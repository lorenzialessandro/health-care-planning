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
    (:action deliver_supply
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply ?u - medical_unit)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (at ?u ?l)
            (box_has_supply ?b ?s)
            (box_unloaded ?b)
            (unit_needs_supply ?u ?s)
        )
        :effect (and
            (not (box_has_supply ?b ?s))
            (empty ?b)
            (not (unit_needs_supply ?u ?s))
            (unit_has_supply ?u ?s)
        )
    )

    ; Load box 
    (:action load_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (box_unloaded ?b)
            (robot_box_empty ?r)
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_robot ?b ?r)
            (not (robot_box_empty ?r))
        )
    )

    ; Unload box
    (:action unload_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (box_loaded_in_robot ?b ?r)
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_robot ?b ?r))
            (robot_box_empty ?r)
            (at ?b ?l)
         )
    )

    ; Movement Boxes

    (:action move_empty_robot_box
        :parameters (?r - robot_box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
            (robot_box_empty ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)
        )
    )
    ; 
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
            (at ?r ?l2)
            (at ?b ?l2)
        )
    )

    ; === Patient operations ===

    ; Pick up patient
    (:action pick_up_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            
            (patient_unloaded ?p)
            (robot_patient_empty ?r)
        )
        :effect (and 
            (not (patient_unloaded ?p))
            (patient_loaded_in_robot ?p ?r)
            (not (robot_patient_empty ?r))
        )
    )

    ; Drop off patient
    (:action drop_off_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (patient_loaded_in_robot ?p ?r)
        )
        :effect (and 
            (patient_unloaded ?p)
            (not (patient_loaded_in_robot ?p ?r))
            (robot_patient_empty ?r)
            (at ?p ?l)
         )
    )

    ; Deliver patient to unit
    (:action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (at ?u ?l)

            (patient_unloaded ?p)
            (patient_needs_unit ?p ?u)
        )
        :effect (and
            (not (patient_needs_unit ?p ?u))
            (patient_at_unit ?p ?u)
        )
    )


    ; Movement Patients

    (:action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
            (robot_patient_empty ?r)
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)
        )
    )

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
            (at ?r ?l2)
            (at ?p ?l2)
        )
    )
)