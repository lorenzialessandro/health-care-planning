(define (domain healthcare)
    (:requirements :strips :typing)
    (:types
        medical_unit box supply robot carrier patient - locatable
        robot_box robot_patient - robot
        location - object
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

        ; Robot predicates
        (robot_has_carrier ?r - robot ?c - carrier)

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

    
    ; === Supply and Box Operations ===

    ; Box Handling Capacity:
    ; - The assumpyion here is that each robot_box has a maximum capacity of 3 boxes
    ; - This requires specific operation sets for different load states:
    ;   * 3 distinct load operations (one per box position)
    ;   * 3 distinct unload operations (one per box position)  
    ;   * 3 distinct movement operations based on load state
    ;
    ; Domain Extensibility:
    ; - The domain structure supports easy extension for larger capacities
    ; - To increase capacity to N boxes, simply add:
    ;   * N load operations
    ;   * N unload operations
    ;   * N movement operations
    ;
    ; Implementation Note:
    ; - Each operation is position-specific to ensure proper state tracking
    ; - Movement operations vary based on the number of loaded boxes
    ; - This design maintains explicit state management while allowing scalability
    

    ; Load operations
    (:action load_first_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)           ; robot has the carrier
            (box_unloaded ?b)                   ; box is unloaded
            (carrier_empty ?c)                  ; carrier is empty : no boxes loaded
            (has_capacity_one ?c)               ; carrier has capacity for one box
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (carrier_empty ?c))
            (has_one_box ?c)                    ; carrier has one box loaded
        )
    )

    (:action load_second_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)           ; robot has the carrier
            (box_unloaded ?b)                   ; box is unloaded
            (has_one_box ?c)                    ; carrier has one box loaded
            (has_capacity_two ?c)               ; carrier has capacity for two boxes
            (box_loaded_in_carrier ?lb1 ?c)     ; first box is loaded
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_one_box ?c))
            (has_two_boxes ?c)                  ; carrier has two boxes loaded
        )
    )

    (:action load_third_box
        :parameters (?r - robot_box ?c - carrier ?b - box  ?lb1 ?lb2 - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)           ; robot has the carrier
            (box_unloaded ?b)                   ; box is unloaded
            (has_two_boxes ?c)                  ; carrier has two boxes loaded
            (has_capacity_three ?c)             ; carrier has capacity for three boxes
            (box_loaded_in_carrier ?lb1 ?c)     ; first box is loaded
            (box_loaded_in_carrier ?lb2 ?c)     ; second box is loaded
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_two_boxes ?c))
            (has_three_boxes ?c)                ; carrier has three boxes loaded
       )
    )

    ; Unload operations
    (:action unload_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)               ; robot has the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_one_box ?c)                        ; carrier has one box loaded
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_one_box ?c))
            (carrier_empty ?c)                      ; carrier is empty : no boxes loaded
            (at ?b ?l)
         )
    )

    (:action unload_from_two
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)               ; robot has the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_two_boxes ?c)                      ; carrier has two boxes loaded
        )
        :effect (and 
            (box_unloaded ?b)                       ; box is unloaded
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_two_boxes ?c))                
            (has_one_box ?c)                        ; carrier has one box loaded
            (at ?b ?l)
         )
    )

    (:action unload_from_three
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)               ; robot has the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_three_boxes ?c)                    ; carrier has three boxes loaded
        )
        :effect (and 
            (box_unloaded ?b)                       ; box is unloaded
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_three_boxes ?c))
            (has_two_boxes ?c)                      ; carrier has two boxes loaded
            (at ?b ?l)
        )
    )

    ; Movement operations

    ; Move empty carrier
    ; causing the update of the carrier location
    (:action move_empty_carrier
        :parameters (?r - robot_box ?c - carrier ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (robot_has_carrier ?r ?c)   ; robot has the carrier
            (connected ?l1 ?l2)         ; check if the locations are connected     
            (carrier_empty ?c)          ; carrier is empty : no boxes loaded
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (at ?r ?l2)             ; robot is at the new location
            (at ?c ?l2)             ; carrier is at the new location
        )
    )

    ; Move carrier with one box
    ; causing the update of the carrier and box location
    (:action move_carrier_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (robot_has_carrier ?r ?c)       ; robot has the carrier
            (connected ?l1 ?l2)
            (has_one_box ?c)
            (box_loaded_in_carrier ?b ?c)   ; box is loaded in the carrier
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b ?l2)            ; box is at the new location
        )
    )

    ; Move carrier with two boxes
    ; causing the update of the carrier and of the two boxes location
    (:action move_carrier_two_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (robot_has_carrier ?r ?c)           ; robot has the carrier
            (connected ?l1 ?l2)
            (has_two_boxes ?c)
            (box_loaded_in_carrier ?b1 ?c)      ; box is loaded in the carrier
            (box_loaded_in_carrier ?b2 ?c)      ; box is loaded in the carrier
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b1 ?l1))
            (not (at ?b2 ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b1 ?l2)        ; box is at the new location
            (at ?b2 ?l2)        ; box is at the new location
        )
    )

    ; Move carrier with three boxes
    ; causing the update of the carrier and of the three boxes location
    (:action move_carrier_three_boxes
        :parameters (?r - robot_box ?c - carrier ?b1 - box ?b2 - box ?b3 - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?c ?l1)
            (robot_has_carrier ?r ?c)           ; robot has the carrier
            (connected ?l1 ?l2)
            (has_three_boxes ?c)
            (box_loaded_in_carrier ?b1 ?c)      ; box is loaded in the carrier
            (box_loaded_in_carrier ?b2 ?c)      ; box is loaded in the carrier
            (box_loaded_in_carrier ?b3 ?c)      ; box is loaded in the carrier
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?c ?l1))
            (not (at ?b1 ?l1))
            (not (at ?b2 ?l1))
            (not (at ?b3 ?l1))
            (at ?r ?l2)
            (at ?c ?l2)
            (at ?b1 ?l2)            ; box is at the new location
            (at ?b2 ?l2)            ; box is at the new location
            (at ?b3 ?l2)            ; box is at the new location
          )
    )
)