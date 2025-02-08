;; Healthcare Domain with Durative Actions
(define (domain healthcare_durative)
    (:requirements :strips :typing :durative-actions)

    (:types
        medical_unit box supply robot_box robot_patient carrier patient - locatable
        location - object
    )

    (:predicates
        ;; Location predicates
        (at ?o - locatable ?l - location)           ; Object ?o is at location ?l
        (connected ?l1 - location ?l2 - location)   ; Location ?l1 is directly connected to ?l2
        
        ;; Box predicates
        (box_loaded_in_carrier ?b - box ?c - carrier)   ; Box ?b is loaded in carrier ?c
        (box_unloaded ?b - box)                         ; Box ?b is not in any carrier
        (empty ?b - box)                                ; Box ?b contains no supplies
        (box_has_supply ?b - box ?s - supply)          ; Box ?b contains supply ?s
        
        ;; Unit predicates
        (unit_needs_supply ?u - medical_unit ?s - supply)    ; Medical unit ?u needs supply ?s
        (unit_has_supply ?u - medical_unit ?s - supply)      ; Medical unit ?u has supply ?s
        
        ;; Carrier capacity tracking predicates
        (has_one_box ?c - carrier)              ; Carrier contains exactly one box
        (has_two_boxes ?c - carrier)            ; Carrier contains exactly two boxes
        (has_three_boxes ?c - carrier)          ; Carrier contains exactly three boxes
        (carrier_empty ?c - carrier)            ; Carrier contains no boxes
        
        ;; Carrier capability predicates
        (has_capacity_one ?c - carrier)         ; Carrier can hold at least one box
        (has_capacity_two ?c - carrier)         ; Carrier can hold at least two boxes
        (has_capacity_three ?c - carrier)       ; Carrier can hold three boxes

        ;; Robot and carrier relationship predicates
        (robot_has_carrier ?r - robot_box ?c - carrier)  ; Robot ?r is connected to carrier ?c

        ;; Patient predicates
        (patient_unloaded ?p - patient)                      ; Patient ?p is not in any robot
        (patient_loaded_in_robot ?p - patient ?r - robot_patient)  ; Patient ?p is in robot ?r
        (patient_needs_unit ?p - patient ?u - medical_unit)       ; Patient ?p needs to go to unit ?u
        (patient_at_unit ?p - patient ?u - medical_unit)         ; Patient ?p is at unit ?u

        ;; Robot state predicates
        (robot_patient_empty ?r - robot_patient)    ; Patient robot ?r is not carrying anyone
        
        ;; Robot busy state tracking (new)
        (robot_box_not_busy ?r - robot_box)        ; Box robot ?r is available for actions
        (robot_patient_not_busy ?r - robot_patient) ; Patient robot ?r is available for actions
    )
    
    ;; === Supply Operations ===
    ;; These actions handle the logistics of supply delivery:
    ;; 1. Filling boxes with supplies
    ;; 2. Delivering supplies to units
    
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
            (at start (not (robot_box_not_busy ?r)))    ; Robot becomes busy

            (at end (not (empty ?b)))                   ; Box if filled
            (at end (box_has_supply ?b ?s))

            (at end (robot_box_not_busy ?r))            ; Robot becomes available
        )
    )
    
    (:durative-action deliver_supply
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply ?u - medical_unit)
        :duration (= ?duration 1) ; 1 time unit to deliver supply
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
            (at start (not (robot_box_not_busy ?r)))    ; Robot becomes busy

            (at end (not (box_has_supply ?b ?s)))
            (at end (empty ?b))
            (at end (not (unit_needs_supply ?u ?s)))
            (at end (unit_has_supply ?u ?s))            ; Unit has the supply

            (at end (robot_box_not_busy ?r))            ; Robot becomes available
        )
    )

        ;; === Patient Operations ===
    ;; These actions handle patient transportation:
    ;; 1. Picking up patients
    ;; 2. Dropping off patients
    ;; 3. Delivering patients to medical units
    (:durative-action pick_up_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :duration (= ?duration 2) ; 2 time units to pick up a patient
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
            (at start (not (robot_patient_not_busy ?r)))    ; Robot becomes busy

            (at end (not (patient_unloaded ?p)))
            (at end (patient_loaded_in_robot ?p ?r))    ; Patient is loaded in robot    
            (at end (not (robot_patient_empty ?r)))

            (at end (robot_patient_not_busy ?r))    ; Robot becomes available
        )
    )

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
            (at start (not (robot_patient_not_busy ?r)))    ; Robot becomes busy

            (at end (patient_unloaded ?p))
            (at end (not (patient_loaded_in_robot ?p ?r)))  ; Patient is unloaded from robot
            (at end (robot_patient_empty ?r))
            (at end (at ?p ?l))

            (at end (robot_patient_not_busy ?r))    ; Robot becomes available
         )
    )

    (:durative-action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :duration (= ?duration 1) ; 1 time unit to deliver a patient
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
            (at start (not (robot_patient_not_busy ?r)))   ; Robot becomes busy

            (at end (not (patient_needs_unit ?p ?u)))
            (at end (patient_at_unit ?p ?u))           ; Patient is at the unit

            (at end (robot_patient_not_busy ?r))    ; Robot becomes available
        )
    )


    ;; === Patient Robot Movement ===
    ;; These actions handle movement of robots carrying patients

    (:durative-action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :duration (= ?duration 2) ; 2 time units to move an empty robot
        :condition (and
            (at start (at ?r ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_patient_empty ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (robot_patient_empty ?r))
        )
        :effect (and
            (at start (not (robot_patient_not_busy ?r)))   ; Robot becomes busy

            (at start (not (at ?r ?l1)))
            (at start (at ?r ?l2))                       ; Robot moves to new location
        
            (at end (robot_patient_not_busy ?r))    ; Robot becomes available
        )
    )

    (:durative-action move_robot_with_patient
        :parameters (?r - robot_patient ?p - patient ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a robot with a patient
        :condition (and
            (at start (at ?r ?l1))
            (at start (connected ?l1 ?l2))
            (at start (patient_loaded_in_robot ?p ?r))

            (at start (robot_patient_not_busy ?r))
            (over all (patient_loaded_in_robot ?p ?r))
        )
        :effect (and
            (at start (not (robot_patient_not_busy ?r)))  ; Robot becomes busy

            (at start (not (at ?r ?l1)))
            (at start (not (at ?p ?l1)))
            (at start (at ?r ?l2))                    ; Robot moves to new location
            (at start (at ?p ?l2))                  ; Patient moves to new location

            (at end (robot_patient_not_busy ?r))    ; Robot becomes available
        )
    )

    
    ;; === Carrier System Operations ===
    ;; These actions implement the multi-box transport system using carriers
    ;; Each operation is position-specific to maintain explicit state tracking


    ;; Load Operations - Three distinct actions for loading boxes based on carrier state
    (:durative-action load_first_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to load a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (at ?b ?l))
            (at start (robot_has_carrier ?r ?c))
            (at start (box_unloaded ?b))
            (at start (carrier_empty ?c))
            (at start (has_capacity_one ?c))

            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))   ; Robot becomes busy

            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))   ; Box is loaded in carrier
            (at end (not (carrier_empty ?c)))
            (at end (has_one_box ?c))             ; Carrier has one box

            (at end (robot_box_not_busy ?r))    ; Robot becomes available
        )
    )

    (:durative-action load_second_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to load a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (at ?b ?l))
            (at start (robot_has_carrier ?r ?c))
            (at start (box_unloaded ?b))      ; Box is not in any carrier
            (at start (has_one_box ?c))            ; Carrier has one box
            (at start (has_capacity_two ?c))    ; Carrier can hold two boxes
            (at start (box_loaded_in_carrier ?lb1 ?c))  ; Carrier already has a box
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))
            (at end (not (has_one_box ?c)))
            (at end (has_two_boxes ?c))            ; Carrier has two boxes
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
            (at start (robot_has_carrier ?r ?c))
            (at start (box_unloaded ?b))
            (at start (has_two_boxes ?c))
            (at start (has_capacity_three ?c))
            (at start (box_loaded_in_carrier ?lb1 ?c))
            (at start (box_loaded_in_carrier ?lb2 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (at ?b ?l))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))
            (at end (not (box_unloaded ?b)))
            (at end (box_loaded_in_carrier ?b ?c))
            (at end (not (has_two_boxes ?c)))
            (at end (has_three_boxes ?c))         ; Carrier has three boxes
            (at end (robot_box_not_busy ?r))
        )
    )

    ;; Unload Operations - Three distinct actions for unloading based on carrier state
    (:durative-action unload_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to unload a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (robot_has_carrier ?r ?c))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_one_box ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))    ; Robot becomes busy
            (at end (box_unloaded ?b))                ; Box is unloaded
            (at end (not (box_loaded_in_carrier ?b ?c)))
            (at end (not (has_one_box ?c))) 
            (at end (carrier_empty ?c))
            (at end (at ?b ?l))
            (at end (robot_box_not_busy ?r))        ; Robot becomes available
         )
    )

    (:durative-action unload_from_two
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 2) ; 2 time units to unload a box
        :condition (and
            (at start (at ?r ?l))
            (at start (at ?c ?l))
            (at start (robot_has_carrier ?r ?c))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_two_boxes ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (robot_has_carrier ?r ?c))
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
            (at start (robot_has_carrier ?r ?c))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (has_three_boxes ?c))
            (at start (robot_box_not_busy ?r))
            (over all (at ?r ?l))
            (over all (at ?c ?l))
            (over all (robot_has_carrier ?r ?c))
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

    ;; === Robot with Carriers Movement ===
    ;; These actions handle movement of robots carrying boxes
    ;; Four distinct actions based on carrier load state

    ; Move empty carrier
    ; causing the update of the carrier location
    (:durative-action move_empty_carrier
        :parameters (?r - robot_box ?c - carrier ?l1 - location ?l2 - location)
        :duration (= ?duration 2) ; 2 time units to move an empty carrier
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_has_carrier ?r ?c))
            (at start (carrier_empty ?c))
            (at start (robot_box_not_busy ?r))

            (over all (carrier_empty ?c))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))   ; Robot becomes busy
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (at ?r ?l2))                  ; Robot moves to new location
            (at start (at ?c ?l2))                ; Carrier moves to new location
            (at end (robot_box_not_busy ?r))    ; Robot becomes available
        )
    )

    ; Move carrier with one box
    ; causing the update of the carrier and box location
    (:durative-action move_carrier_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with one box
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_has_carrier ?r ?c))
            (at start (has_one_box ?c))
            (at start (box_loaded_in_carrier ?b ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b ?c))
            (over all (robot_has_carrier ?r ?c))
        )
        :effect (and 
            (at start (not (robot_box_not_busy ?r)))    ; Robot becomes busy
            (at start (not (at ?r ?l1)))
            (at start (not (at ?c ?l1)))
            (at start (not (at ?b ?l1)))
            (at start (at ?r ?l2))                ; Robot moves to new location
            (at start (at ?c ?l2))                ; Carrier moves to new location
            (at start (at ?b ?l2))                  ; Box moves to new location
            (at end (robot_box_not_busy ?r))        ; Robot becomes available
        )
    )

    ; Move carrier with two boxes
    ; causing the update of the carrier and of the two boxes locatio
    (:durative-action move_carrier_two_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with two boxes
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_has_carrier ?r ?c))
            (at start (has_two_boxes ?c))
            (at start (box_loaded_in_carrier ?b1 ?c))
            (at start (box_loaded_in_carrier ?b2 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b1 ?c))
            (over all (box_loaded_in_carrier ?b2 ?c))
            (over all (robot_has_carrier ?r ?c))
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

    ; Move carrier with three boxes
    ; causing the update of the carrier and of the three boxes location
    (:durative-action move_carrier_three_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?b3 - box ?l1 - location ?l2 - location)
        :duration (= ?duration 3) ; 3 time units to move a carrier with three boxes
        :condition (and
            (at start (at ?r ?l1))
            (at start (at ?c ?l1))
            (at start (connected ?l1 ?l2))
            (at start (robot_has_carrier ?r ?c))
            (at start (has_three_boxes ?c))
            (at start (box_loaded_in_carrier ?b1 ?c))
            (at start (box_loaded_in_carrier ?b2 ?c))
            (at start (box_loaded_in_carrier ?b3 ?c))
            (at start (robot_box_not_busy ?r))
            (over all (box_loaded_in_carrier ?b1 ?c))
            (over all (box_loaded_in_carrier ?b2 ?c))
            (over all (box_loaded_in_carrier ?b3 ?c))
            (over all (robot_has_carrier ?r ?c))
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