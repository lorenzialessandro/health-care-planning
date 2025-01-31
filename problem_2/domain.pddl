(define (domain healthcare)
    (:requirements :strips :typing)
    (:types
        medical_unit box supply robot patient - locatable
        robot_box robot_patient - robot
        location carrier - object
    )

    (:predicates
        ; Location predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
        
        ; Box predicates
        (box_loaded_in_carrier ?b - box ?c - carrier)
        (box_unloaded ?b - box)
        (empty ?b - box)
        (box_has_supply ?b - box ?s - supply)
        
        ; Unit predicates
        (unit_needs_supply ?u - medical_unit ?s - supply)
        (unit_has_supply ?u - medical_unit ?s - supply)
        
        ; Carrier capacity tracking
        (has_one_box ?c - carrier)
        (has_two_boxes ?c - carrier)
        (has_three_boxes ?c - carrier)
        
        (carrier_empty ?c - carrier)
        
        (has_capacity_one ?c - carrier)
        (has_capacity_two ?c - carrier)
        (has_capacity_three ?c - carrier)

        ; Patient predicates
        (patient_unloaded ?p - patient)
        (patient_loaded_in_robot ?p - patient ?r - robot_patient)
        (patient_needs_unit ?p - patient ?u - medical_unit)
        (patient_at_unit ?p - patient ?u - medical_unit)

        ; Robot patient predicates
        (robot_patient_empty ?r - robot_patient)
        
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

    ; === Load and unload operations ===

    ; Load operations
    (:action load_first_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (box_unloaded ?b)
            (carrier_empty ?c)
            (has_capacity_one ?c)
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (carrier_empty ?c))
            (has_one_box ?c)
        )
    )

    (:action load_second_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (box_unloaded ?b)
            (has_one_box ?c)
            (has_capacity_two ?c)
            (box_loaded_in_carrier ?lb1 ?c)
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_one_box ?c))
            (has_two_boxes ?c)
        )
    )

    (:action load_third_box
        :parameters (?r - robot_box ?c - carrier ?b - box  ?lb1 ?lb2 - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (box_unloaded ?b)
            (has_two_boxes ?c)
            (has_capacity_three ?c)
            (box_loaded_in_carrier ?lb1 ?c)
            (box_loaded_in_carrier ?lb2 ?c)
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_two_boxes ?c))
            (has_three_boxes ?c)
       )
    )

    ; Unload operations
    (:action unload_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (box_loaded_in_carrier ?b ?c)
            (has_one_box ?c)
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_one_box ?c))
            (carrier_empty ?c)
            (at ?b ?l)
         )
    )

    (:action unload_from_two
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (box_loaded_in_carrier ?b ?c)
            (has_two_boxes ?c)
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_two_boxes ?c))
            (has_one_box ?c)
            (at ?b ?l)
         )
    )

    (:action unload_from_three
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (box_loaded_in_carrier ?b ?c)
            (has_three_boxes ?c)
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_three_boxes ?c))
            (has_two_boxes ?c)
            (at ?b ?l)
        )
    )

    ; === Movement operations ===

    (:action move_empty_carrier
        :parameters (?r - robot_box ?c - carrier ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (connected ?l1 ?l2)
            (carrier_empty ?c)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
        )
    )

    (:action move_carrier_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (connected ?l1 ?l2)
            (has_one_box ?c)
            (box_loaded_in_carrier ?b ?c)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b ?l2)
        )
    )

    (:action move_carrier_two_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (connected ?l1 ?l2)
            (has_two_boxes ?c)
            (box_loaded_in_carrier ?b1 ?c)
            (box_loaded_in_carrier ?b2 ?c)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b1 ?l1))
            (not (at ?b2 ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b1 ?l2)
            (at ?b2 ?l2)
        )
    )

    (:action move_carrier_three_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?b3 - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (connected ?l1 ?l2)
            (has_three_boxes ?c)
            (box_loaded_in_carrier ?b1 ?c)
            (box_loaded_in_carrier ?b2 ?c)
            (box_loaded_in_carrier ?b3 ?c)
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b1 ?l1))
            (not (at ?b2 ?l1))
            (not (at ?b3 ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b1 ?l2)
            (at ?b2 ?l2)
            (at ?b3 ?l2)
          )
    )
)