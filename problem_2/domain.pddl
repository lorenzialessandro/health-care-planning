;; Healthcare Domain with Carrier System
(define (domain healthcare)
    (:requirements :strips :typing)
    
    ;; Type Hierarchy
    ;; - locatable: Base type for all objects that can be at a location
    ;;   - medical_unit: Hospital units that need supplies and receive patients
    ;;   - box: Containers for transporting supplies
    ;;   - supply: Medical supplies that need to be delivered
    ;;   - carrier: Container platform that can hold multiple boxes
    ;;   - robot: Base type for all robots
    ;;     - robot_box: Specialized robots for carrying carriers with boxes
    ;;     - robot_patient: Specialized robots for transporting patients
    ;;   - patient: Patients that need to be transported to medical units
    (:types
        medical_unit box supply robot carrier patient - locatable
        robot_box robot_patient - robot
        location - object
    )

    (:predicates
        ;; Location predicates - Track positions of objects
        (at ?o - locatable ?l - location)           ; Object ?o is at location ?l
        (connected ?l1 - location ?l2 - location)   ; Location ?l1 is directly connected to ?l2
        
        ;; Box predicates - Track box states and contents
        (box_loaded_in_carrier ?b - box ?c - carrier)   ; Box ?b is loaded in carrier ?c
        (box_unloaded ?b - box)                         ; Box ?b is not in any carrier
        (empty ?b - box)                                ; Box ?b contains no supplies
        (box_has_supply ?b - box ?s - supply)          ; Box ?b contains supply ?s
        
        ;; Unit predicates - Track medical unit needs and inventory
        (unit_needs_supply ?u - medical_unit ?s - supply)    ; Medical unit ?u needs supply ?s
        (unit_has_supply ?u - medical_unit ?s - supply)      ; Medical unit ?u has supply ?s
        
        ;; Carrier predicates - Track load state and capacity
        (has_one_box ?c - carrier)              ; Carrier contains exactly one box
        (has_two_boxes ?c - carrier)            ; Carrier contains exactly two boxes
        (has_three_boxes ?c - carrier)          ; Carrier contains exactly three boxes
        (carrier_empty ?c - carrier)            ; Carrier contains no boxes
        
        (has_capacity_one ?c - carrier)         ; Carrier can hold at least one box
        (has_capacity_two ?c - carrier)         ; Carrier can hold at least two boxes
        (has_capacity_three ?c - carrier)       ; Carrier can hold three boxes

        ;; Robot predicates - Track robot-carrier relationships
        (robot_has_carrier ?r - robot_box ?c - carrier)  ; Robot ?r is connected to carrier ?c

        ;; Patient predicates - Track patient states and needs
        (patient_unloaded ?p - patient)                      ; Patient ?p is not in any robot
        (patient_loaded_in_robot ?p - patient ?r - robot_patient)  ; Patient ?p is in robot ?r
        (patient_needs_unit ?p - patient ?u - medical_unit)       ; Patient ?p needs to go to unit ?u
        (patient_at_unit ?p - patient ?u - medical_unit)         ; Patient ?p is at unit ?u

        ;; Robot patient predicates - Track patient robot availability
        (robot_patient_empty ?r - robot_patient)    ; Patient robot ?r is not carrying anyone
    )
    
    ;; === Supply Operations ===
    ;; These actions handle the logistics of supply delivery:
    ;; 1. Filling boxes with supplies
    ;; 2. Delivering supplies to units
    (:action fill_box
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply)
        :precondition (and
            (at ?r ?l)        ; Robot must be at the location
            (at ?b ?l)        ; Box must be at the location
            (at ?s ?l)        ; Supply must be at the location
            (box_unloaded ?b) ; Box must not be in a carrier
            (empty ?b)        ; Box must be empty
        )
        :effect (and 
            (not (empty ?b))
            (box_has_supply ?b ?s)  ; Box now contains the supply
        )
    )

    (:action deliver_supply
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply ?u - medical_unit)
        :precondition (and
            (at ?r ?l)                    ; All objects must be at same location
            (at ?b ?l)
            (at ?u ?l)
            (box_has_supply ?b ?s)        ; Box must contain the needed supply
            (box_unloaded ?b)             ; Box must not be in a carrier
            (unit_needs_supply ?u ?s)     ; Unit must need this supply
        )
        :effect (and
            (not (box_has_supply ?b ?s))  ; Remove supply from box
            (empty ?b)                     ; Box becomes empty
            (not (unit_needs_supply ?u ?s))
            (unit_has_supply ?u ?s)        ; Unit now has the supply
        )
    )

    ;; === Patient Operations ===
    ;; These actions handle patient transportation:
    ;; 1. Picking up patients
    ;; 2. Dropping off patients
    ;; 3. Delivering patients to medical units

    (:action pick_up_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)                    ; Robot and patient at same location
            (at ?p ?l)
            (patient_unloaded ?p)         ; Patient must not be in another robot
            (robot_patient_empty ?r)      ; Robot must be available
        )
        :effect (and 
            (not (patient_unloaded ?p))
            (patient_loaded_in_robot ?p ?r)  ; Patient is now in robot
            (not (robot_patient_empty ?r))   ; Robot is no longer empty
        )
    )

    (:action drop_off_patient
        :parameters (?r - robot_patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (patient_loaded_in_robot ?p ?r)  ; Patient must be in this robot
        )
        :effect (and 
            (patient_unloaded ?p)            ; Patient is removed from robot
            (not (patient_loaded_in_robot ?p ?r))
            (robot_patient_empty ?r)         ; Robot becomes available
            (at ?p ?l)                       ; Patient is at the location
         )
    )

    (:action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :precondition (and
            (at ?r ?l)                    ; All objects at same location
            (at ?p ?l)
            (at ?u ?l)
            (patient_unloaded ?p)         ; Patient must not be in a robot
            (patient_needs_unit ?p ?u)    ; Patient must need this unit
        )
        :effect (and
            (not (patient_needs_unit ?p ?u))
            (patient_at_unit ?p ?u)         ; Patient is now at their needed unit
        )
    )

    ;; === Patient Robot Movement ===
    ;; These actions handle movement of robots carrying patients

    (:action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)           ; Locations must be connected
            (robot_patient_empty ?r)      ; Robot must not be carrying a patient
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)                   ; Robot moves to new location
        )
    )

    (:action move_robot_with_patient
        :parameters (?r - robot_patient ?p - patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)               ; Locations must be connected
            (patient_loaded_in_robot ?p ?r)   ; Robot must be carrying this patient
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?p ?l1))
            (at ?r ?l2)                       ; Both robot and patient move
            (at ?p ?l2)                       ; to the new location
        )
    )

    ;; === Carrier System Operations ===
    ;; These actions implement the multi-box transport system using carriers
    ;; Each operation is position-specific to maintain explicit state tracking

    ;; Box Handling Capacity:
    ;; - The assumpyion here is that each robot_box has a maximum capacity of 3 boxes
    ;; - This requires specific operation sets for different load states:
    ;;   * 3 distinct load operations (one per box position)
    ;;   * 3 distinct unload operations (one per box position)  
    ;;   * 3 distinct movement operations based on load state
    ;;
    ;; Domain Extensibility:
    ;; - The domain structure supports easy extension for larger capacities
    ;; - To increase capacity to N boxes, simply add:
    ;;   * N load operations
    ;;   * N unload operations
    ;;   * N movement operations
    ;;
    ;; Implementation Note:
    ;; - Each operation is position-specific to ensure proper state tracking
    ;; - Movement operations vary based on the number of loaded boxes
    ;; - This design maintains explicit state management while allowing scalability

    ;; Load Operations - Three distinct actions for loading boxes based on carrier state
    (:action load_first_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)                    ; All objects at same location
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_unloaded ?b)             ; Box must be unloaded
            (carrier_empty ?c)            ; Carrier must be empty
            (has_capacity_one ?c)         ; Carrier must have minimum capacity
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (carrier_empty ?c))
            (has_one_box ?c)              ; Update carrier state
        )
    )

    (:action load_second_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 - box ?l - location)
        :precondition (and
            (at ?r ?l)                    ; All objects at same location
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_unloaded ?b)             ; New box must be unloaded
            (has_one_box ?c)              ; Carrier must have exactly one box
            (has_capacity_two ?c)         ; Carrier must have capacity for two
            (box_loaded_in_carrier ?lb1 ?c)  ; First box must be loaded
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_one_box ?c))
            (has_two_boxes ?c)            ; Update carrier state
        )
    )

    (:action load_third_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?lb1 ?lb2 - box ?l - location)
        :precondition (and
            (at ?r ?l)                    ; All objects at same location
            (at ?c ?l)
            (at ?b ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_unloaded ?b)             ; New box must be unloaded
            (has_two_boxes ?c)            ; Carrier must have exactly two boxes
            (has_capacity_three ?c)       ; Carrier must have capacity for three
            (box_loaded_in_carrier ?lb1 ?c)  ; First box must be loaded
            (box_loaded_in_carrier ?lb2 ?c)  ; Second box must be loaded
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_carrier ?b ?c)
            (not (has_two_boxes ?c))
            (has_three_boxes ?c)          ; Update carrier state
        )
    )

    ;; Unload Operations - Three distinct actions for unloading based on carrier state
    (:action unload_one_box
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_one_box ?c)              ; Carrier must have exactly one box
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_one_box ?c))
            (carrier_empty ?c)            ; Carrier becomes empty
            (at ?b ?l)                    ; Box is at the location
         )
    )

    (:action unload_from_two
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_two_boxes ?c)            ; Carrier must have exactly two boxes
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_two_boxes ?c))
            (has_one_box ?c)              ; Carrier now has one box
            (at ?b ?l)                    ; Box is at the location
         )
    )

    (:action unload_from_three
        :parameters (?r - robot_box ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?c ?l)
            (robot_has_carrier ?r ?c)     ; Robot must have the carrier
            (box_loaded_in_carrier ?b ?c)
            (has_three_boxes ?c)          ; Carrier must have three boxes
        )
        :effect (and 
            (box_unloaded ?b)
            (not (box_loaded_in_carrier ?b ?c))
            (not (has_three_boxes ?c))
            (has_two_boxes ?c)            ; Carrier now has two boxes
            (at ?b ?l)                    ; Box is at the location
        )
    )

    ;; === Robot with Carriers Movement ===
    ;; These actions handle movement of robots carrying boxes
    ;; Four distinct actions based on carrier load state

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

    ; Move carrier with one box causing the update of the carrier and box location
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

    ; Move carrier with two boxes causing the update of the carrier and of the two boxes location
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

    ; Move carrier with three boxes causing the update of the carrier and of the three boxes location
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