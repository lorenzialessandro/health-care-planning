;; Healthcare Basic Domain
(define (domain healthcare_basic)
    (:requirements :strips :typing)
    
    ;; Type Hierarchy
    ;; - locatable: Base type for all objects that can be at a location
    ;;   - medical_unit: Hospital units that need supplies and receive patients
    ;;   - box: Containers for transporting supplies
    ;;   - supply: Medical supplies that need to be delivered
    ;;   - robot: Base type for all robots
    ;;     - robot_box: Specialized robots for carrying boxes
    ;;     - robot_patient: Specialized robots for transporting patients
    ;;   - patient: Patients that need to be transported to medical units
    (:types
        medical_unit box supply robot patient - locatable
        robot_box robot_patient - robot
        location - object
    )

    ;; Predicates are organized into categories:
    ;; - Location predicates: Track positions of objects
    ;; - Box predicates: Track box states and contents
    ;; - Unit predicates: Track medical unit needs and inventory
    ;; - Patient predicates: Track patient states and needs
    ;; - Robot predicates: Track robot availability
    (:predicates
        ;; Location predicates
        (at ?o - locatable ?l - location)           ; Object ?o is at location ?l
        (connected ?l1 - location ?l2 - location)   ; Location ?l1 is directly connected to ?l2
        
        ;; Box predicates
        (box_loaded_in_robot ?b - box ?r - robot_box)   ; Box ?b is loaded in robot ?r
        (box_unloaded ?b - box)                         ; Box ?b is not in any robot
        (empty ?b - box)                                ; Box ?b contains no supplies
        (box_has_supply ?b - box ?s - supply)          ; Box ?b contains supply ?s
        
        ;; Unit predicates
        (unit_needs_supply ?u - medical_unit ?s - supply)    ; Medical unit ?u needs supply ?s
        (unit_has_supply ?u - medical_unit ?s - supply)      ; Medical unit ?u has supply ?s
        
        ;; Patient predicates
        (patient_unloaded ?p - patient)                      ; Patient ?p is not in any robot
        (patient_loaded_in_robot ?p - patient ?r - robot_patient)  ; Patient ?p is in robot ?r
        (patient_needs_unit ?p - patient ?u - medical_unit)       ; Patient ?p needs to go to unit ?u
        (patient_at_unit ?p - patient ?u - medical_unit)         ; Patient ?p is at unit ?u

        ;; Robot predicates
        (robot_patient_empty ?r - robot_patient)    ; Patient robot ?r is not carrying anyone
        (robot_box_empty ?r - robot_box)           ; Box robot ?r is not carrying anything
    )
    
    ;; === Supply Operations ===
    ;; These actions handle the logistics of supply delivery:
    ;; 1. Filling boxes with supplies
    ;; 2. Delivering supplies to units
    ;; 3. Loading/unloading boxes from robots
    
    (:action fill_box
        :parameters (?r - robot_box ?b - box ?l - location ?s - supply)
        :precondition (and
            (at ?r ?l)        ; Robot must be at the location
            (at ?b ?l)        ; Box must be at the location
            (at ?s ?l)        ; Supply must be at the location
            (box_unloaded ?b) ; Box must not be in a robot
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
            (at ?r ?l)                    ; All objects must be at the same location
            (at ?b ?l)
            (at ?u ?l)
            (box_has_supply ?b ?s)        ; Box must contain the needed supply
            (box_unloaded ?b)             ; Box must not be in a robot
            (unit_needs_supply ?u ?s)     ; Unit must need this supply
        )
        :effect (and
            (not (box_has_supply ?b ?s))  ; Remove supply from box
            (empty ?b)                     ; Box becomes empty
            (not (unit_needs_supply ?u ?s))
            (unit_has_supply ?u ?s)        ; Unit now has the supply
        )
    )

    (:action load_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)                ; Robot and box must be at same location
            (at ?b ?l)
            (box_unloaded ?b)         ; Box must not be in another robot
            (robot_box_empty ?r)      ; Robot must be available
        )
        :effect (and 
            (not (box_unloaded ?b))
            (box_loaded_in_robot ?b ?r)  ; Box is now in the robot
            (not (robot_box_empty ?r))   ; Robot is no longer empty
        )
    )

    (:action unload_box
        :parameters (?r - robot_box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (box_loaded_in_robot ?b ?r)  ; Box must be in this robot
        )
        :effect (and 
            (box_unloaded ?b)            ; Box is removed from robot
            (not (box_loaded_in_robot ?b ?r))
            (robot_box_empty ?r)         ; Robot becomes available
            (at ?b ?l)                   ; Box is now at the location
         )
    )

    ;; === Robot Box Movement ===
    ;; These actions handle the movement of robots carrying boxes:
    ;; 1. Moving empty box robots
    ;; 2. Moving robots with loaded boxes

    (:action move_empty_robot_box
        :parameters (?r - robot_box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)       ; Locations must be directly connected
            (robot_box_empty ?r)      ; Robot must not be carrying a box
        )
        :effect (and 
            (not (at ?r ?l1))
            (at ?r ?l2)               ; Robot moves to new location
        )
    )

    (:action move_robot_with_box
        :parameters (?r - robot_box ?b - box ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)           ; Locations must be directly connected
            (box_loaded_in_robot ?b ?r)   ; Robot must be carrying this box
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?b ?l1))
            (at ?r ?l2)                   ; Both robot and box move
            (at ?b ?l2)                   ; to the new location
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
            (at ?r ?l)                ; Robot and patient must be at same location
            (at ?p ?l)
            (patient_unloaded ?p)     ; Patient must not be in another robot
            (robot_patient_empty ?r)   ; Robot must be available
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
            (at ?p ?l)                       ; Patient is now at the location
         )
    )

    (:action deliver_patient
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - medical_unit)
        :precondition (and
            (at ?r ?l)                    ; All objects must be at same location
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
    ;; These actions handle the movement of robots carrying patients:
    ;; 1. Moving empty patient robots
    ;; 2. Moving robots with patients

    (:action move_empty_robot_patient
        :parameters (?r - robot_patient ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)           ; Locations must be directly connected
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
            (connected ?l1 ?l2)               ; Locations must be directly connected
            (patient_loaded_in_robot ?p ?r)   ; Robot must be carrying this patient
        )
        :effect (and 
            (not (at ?r ?l1))
            (not (at ?p ?l1))
            (at ?r ?l2)                       ; Both robot and patient move
            (at ?p ?l2)                       ; to the new location
        )
    )
)