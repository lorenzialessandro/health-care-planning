(define (domain healthcare_durative)
    (:requirements :strips :typing :durative-actions)
    (:types
        medical_unit box supply robot_box robot_patient carrier patient - locatable
        location  - object
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

        ; Predicate to track busy robots (new)
        (robot_box_not_busy ?r - robot_box)
        (robot_patient_not_busy ?r - robot_patient)
        
    )
    

    ; === Supply operations ===

    ; Fill box with supply
    (:durative-action fill_box
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply)
        :duration (= ?duration 3) ; 3 time units to fill a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?b ?l))
            (at start (at ?s ?l))
            (at start (box_unloaded ?b))
            (at start (empty ?b))

            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?b ?l))
            (over all (at ?s ?l))
            (over all (box_unloaded ?b))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))

            (at end (not (empty ?b)))
            (at end (box_has_supply ?b ?s))

            (at end (robot_box_not_busy ?r))
        )
    )

    ; Deliver supply to unit
    (:durative-action deliver_supply
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply ?u - medical_unit)
        :duration (= ?duration 2) ; 2 time units to deliver supply
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?b ?l))
            (at start (at ?u ?l))
            (at start (box_has_supply ?b ?s))
            (at start (box_unloaded ?b))
            (at start (unit_needs_supply ?u ?s))

            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?b ?l))
            (over all (box_unloaded ?b))
        )
        :effect (and
            (at start (not (robot_box_not_busy ?r)))

            (at end (not (box_has_supply ?b ?s)))
            (at end (empty ?b))
            (at end (not (unit_needs_supply ?u ?s)))
            (at end (unit_has_supply ?u ?s))

            (at end (robot_box_not_busy ?r))
        )
    )

    ; === Patient operations ===

    ; Pick up patient
    (:durative-action pick_up_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :duration (= ?duration 3) ; 3 time units to pick up a patient
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?p ?l))
            (at start (patient_unloaded ?p))
            (at start (robot_patient_empty ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?p ?l))
        )
        :effect (and 
            (at start (not (robot_patient_not_busy ?r)))

            (at end (not (patient_unloaded ?p)))
            (at end (patient_loaded_in_robot ?p ?r))
            (at end (not (robot_patient_empty ?r)))

            (at end (robot_patient_not_busy ?r))
        )
    )

    ; Drop off patient
    (:durative-action drop_off_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :duration (= ?duration 2) ; 2 time units to drop off a patient
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?p ?l))
            (at start (patient_loaded_in_robot ?p ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?p ?l))
        )
        :effect (and 
            (at start (not (robot_patient_not_busy ?r)))

            (at end (patient_unloaded ?p))
            (at end (not (patient_loaded_in_robot ?p ?r)))
            (at end (robot_patient_empty ?r))
            (at end (at ?p ?l))

            (at end (robot_patient_not_busy ?r))
         )
    )

    ; Deliver patient to unit
    (:durative-action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :duration (= ?duration 5) ; 5 time units to deliver a patient
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?p ?l))
            (at start (at ?u ?l))
            (at start (patient_unloaded ?p))
            (at start (patient_needs_unit ?p ?u))

            (at start (robot_patient_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?p ?l))
            (over all (patient_unloaded ?p))
        )
        :effect (and
            (at start (not (robot_patient_not_busy ?r)))

            (at end (not (patient_needs_unit ?p ?u)))
            (at end (patient_at_unit ?p ?u))

            (at end (robot_patient_not_busy ?r))
        )
    )


    ; Movement Patients

    (:durative-action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :duration (= ?duration 1) ; 1 time units to move an empty robot
        :condition (and
            (at start (at ?r ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_patient_empty ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (robot_patient_empty ?r))
        )
        :effect (and
            (at start (not (robot_patient_not_busy ?r)))

            (at start (not (at ?r ?l1)))
            (at start (at ?r ?l2))
        
            (at end (robot_patient_not_busy ?r))
        )
    )

    (:durative-action move_robot_with_patient
        :parameters (?r - robot_patient ?p - patient ?l1 - location ?l2 - location)
        :duration (= ?duration 2) ; 2 time units to move a robot with a patient
        :condition (and
            (at start (at ?r ?l1))
            (at start (connected ?l1 ?l2))
            (at start (patient_loaded_in_robot ?p ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (patient_loaded_in_robot ?p ?r))
        )
        :effect (and
            (at start (not (robot_patient_not_busy ?r)))

            (at start (not (at ?r ?l1)))
            (at start (not (at ?p ?l1)))
            (at start (at ?r ?l2))
            (at start (at ?p ?l2))

            (at end (robot_patient_not_busy ?r))
        )
    )

    ; === Load and unload operations ===

    ; Load operations
    (:durative-action load_first_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to load a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (at ?b ?l))
            (at start (box_unloaded ?b))
            (at start (carrier_empty ?c))
            (at start (has_capacity_one ?c))

            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))

            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))
            (at end (not (carrier_empty ?c)))
            (at end (has_one_box ?c))

            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action load_second_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to load a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (at ?b ?l))
            (at start (box_unloaded ?b))
            (at start (has_one_box ?c))
            (at start (has_capacity_two ?c))
            (at start (box_loaded_in_carrier ?lb1 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))
            (at end (not (has_one_box ?c)))
            (at end (has_two_boxes ?c))
            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action load_third_box
        :parameters (?r - robot_box ?c - carrier ?b - box  ?lb1 ?lb2 - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to load a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (at ?b ?l))
            (at start (box_unloaded ?b))
            (at start (has_two_boxes ?c))
            (at start (has_capacity_three ?c))
            (at start (box_loaded_in_carrier ?lb1 ?c))
            (at start (box_loaded_in_carrier ?lb2 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))
            (at end (not (has_two_boxes ?c)))
            (at end (has_three_boxes ?c))
            (at end (robot_box_not_busy ?r))
        )
    )

    ; Unload operations
    (:durative-action unload_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to unload a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_one_box ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (box_unloaded ?b))
            (at end (not (box_loaded_in_carrier ?b ?c)))
            (at end (not (has_one_box ?c)))
            (at end (carrier_empty ?c))
            (at end (at ?b ?l))
            (at end (robot_box_not_busy ?r))
         )
    )

    (:durative-action unload_from_two
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to unload a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_two_boxes ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (box_unloaded ?b))
            (at end (not (box_loaded_in_carrier ?b ?c)))
            (at end (not (has_two_boxes ?c)))
            (at end (has_one_box ?c))
            (at end (at ?b ?l))
            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action unload_from_three
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to unload a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_three_boxes ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (box_unloaded ?b))
            (at end (not (box_loaded_in_carrier ?b ?c)))
            (at end (not (has_three_boxes ?c)))
            (at end (has_two_boxes ?c))
            (at end (at ?b ?l))
            (at end (robot_box_not_busy ?r))
        )
    )

    ; === Movement operations ===

    (:durative-action move_empty_carrier
        :parameters (?r - robot_box ?c - carrier ?l1 - location ?l2 - location)
        :duration (= ?duration 1) ; 1 time units to move an empty carrier
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (carrier_empty ?c))
            (at start (robot_box_not_busy ?r))

            (over all (carrier_empty ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (at ?r ?l2))
            (at start (at ?c ?l2))
            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action move_carrier_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with one box
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (has_one_box ?c))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (not (at ?b ?l1)))
            (at start (at ?r ?l2))
            (at start (at ?c ?l2))
            (at start (at ?b ?l2))
            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action move_carrier_two_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with two boxes
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (has_two_boxes ?c))
            (at start (box_loaded_in_carrier ?b1 ?c))
            (at start (box_loaded_in_carrier ?b2 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b1 ?c))
            (over all (box_loaded_in_carrier ?b2 ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (not (at ?b1 ?l1)))
            (at start (not (at ?b2 ?l1)))
            (at start (at ?r ?l2))
            (at start (at ?c ?l2))
            (at start (at ?b1 ?l2))
            (at start (at ?b2 ?l2))
            (at end (robot_box_not_busy ?r))
        )
    )

    (:durative-action move_carrier_three_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?b3 - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with three boxes
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (has_three_boxes ?c))
            (at start (box_loaded_in_carrier ?b1 ?c))
            (at start (box_loaded_in_carrier ?b2 ?c))
            (at start (box_loaded_in_carrier ?b3 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b1 ?c))
            (over all (box_loaded_in_carrier ?b2 ?c))
            (over all (box_loaded_in_carrier ?b3 ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (not (at ?b1 ?l1)))
            (at start (not (at ?b2 ?l1)))
            (at start (not (at ?b3 ?l1)))
            (at start (at ?r ?l2))
            (at start (at ?c ?l2))
            (at start (at ?b1 ?l2))
            (at start (at ?b2 ?l2))
            (at start (at ?b3 ?l2))
            (at end (robot_box_not_busy ?r))
        )
    )
)