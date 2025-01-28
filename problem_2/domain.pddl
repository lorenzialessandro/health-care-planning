(define (domain health-care)
    (:requirements :adl)

    (:types
        medical-unit box content robot patient - locatable
        robot-box robot-patient - robot
        location 
        carrier 
        capacity-num - object
    )

    (:predicates
        ; location predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
        (is-central_warehouse ?l - location)
        ; box predicates
        (empty ?b - box)
        (box-has-content ?b - box ?c - content)
        ; content predicates
        (content-available ?c - content ?l - location)
        (unit-needs-content ?u - medical-unit ?c - content)
        (unit-has-content ?u - medical-unit ?c - content)
        ; patient predicates
        (patient-needs-unit ?p - patient ?u - medical-unit)
        (patient-at-unit ?p - patient ?u - medical-unit)
        ; robot-box with CARRIER predicates
        (robot-has-carrier ?r - robot ?cr - carrier)
        (box-in-carrier ?b - box ?cr - carrier)
        ; carrier capacity predicates
        (carrier-has-capacity ?cr - carrier ?n - capacity-num) ; that's the maximum capacity of the carrier
        (next-capacity ?n1 - capacity-num ?n2 - capacity-num)
        (carrier-current-capacity ?cr - carrier ?n - capacity-num)
        ; robot-patient predicates
        (robot-has-patient ?r - robot-patient ?p - patient)
    )

    (:action load-box-carrier
        :parameters (?r - robot-box ?b - box ?c - carrier ?l - location ?current ?next ?max - capacity-num)
        :precondition (and
            ; box and robot are at the same location
            (at ?r ?l)
            (at ?b ?l)
            ; robot has that carrier
            (robot-has-carrier ?r ?c)

            ; if location is central_warehouse, then the box must be full
            (or
                (not (is-central_warehouse ?l)) 
                (not (empty ?b))
            )

            (carrier-current-capacity ?c ?current)
            (next-capacity ?current ?next)
            (carrier-has-capacity ?c ?max) 

            ; check that carrier is not already full
            (not (next-capacity ?current ?max)) ; if the current capacity is the maximum, then the carrier is full => no more boxes can be             
        )
        :effect (and
            (box-in-carrier ?b ?c)
            (not (carrier-current-capacity ?c ?current))
            (carrier-current-capacity ?c ?next)
        )
    )


    (:action fill-box
        :parameters (?r - robot-box ?cr - carrier ?b - box ?c - content ?l - location)
        :precondition (and
            ; box and robot are at the same location
            (at ?r ?l)
            (at ?b ?l)
            ; robot has that carrier
            (robot-has-carrier ?r ?cr)
            ; box is empty
            (empty ?b)
            ; content is available at the location
            (content-available ?c ?l)

            (or
                (box-in-carrier ?b ?cr) ; if the box is in the carrier and it is empty (up), then it can be reutilized and filled with a new content
                (not (exists (?cr2 - carrier) (box-in-carrier ?b ?cr2))) ; if the box is not in the carrier, then it can be filled with a new content
            )
        )
        :effect (and
            (not (empty ?b))
            (box-has-content ?b ?c)
            (not (content-available ?c ?l)) 
        )
    )

    (:action move-robot-box
        :parameters (?r - robot-box ?cr - carrier ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (not (= ?from ?to))
            (robot-has-carrier ?r ?cr)

            ; robot does not have to return to the central_warehouse until all boxes on the carrier have been delivered
            (or
                ; if destination is not the central_warehouse robot can move always
                (not (is-central_warehouse ?to)) 
                ; if destination is the central_warehouse, then the carrier must be empty: no box is in the carrier that are not empty
                (and 
                    (is-central_warehouse ?to)
                    (not (exists (?b - box)
                        (and 
                            (box-in-carrier ?b ?cr)
                            (not (empty ?b))
                        )    
                    ))
                )
            )
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            ; Move box if robot is carrying in its carrier
            (forall
                (?b - box)
                (when
                    (box-in-carrier ?b ?cr)
                    (and
                        (at ?b ?to)
                        (not (at ?b ?from))
                    )
                )
            )
        )
    )

    (:action deliver-content
        :parameters (?r - robot-box ?cr - carrier ?b - box ?u - medical-unit ?c - content ?l - location ?current ?prev - capacity-num)
        :precondition (and
            (at ?r ?l)
            (at ?u ?l)
            (robot-has-carrier ?r ?cr)

            (box-in-carrier ?b ?cr)
            (box-has-content ?b ?c)
            
            (unit-needs-content ?u ?c) ; the predicate "unit-needs-content" is an extra check to avoid delivering content to a unit that does not need it, so to avoid extra moves
            
            (carrier-current-capacity ?cr ?current)
            (next-capacity ?prev ?current)
            
            (not (empty ?b))
        )
        :effect (and
            (unit-has-content ?u ?c)
            (not (unit-needs-content ?u ?c))
            (not (box-has-content ?b ?c))
            (not (box-in-carrier ?b ?cr)) ; the box is no longer in the carrier

            (empty ?b)
            
            ; update carrier load
            (not (carrier-current-capacity ?cr ?current))
            (carrier-current-capacity ?cr ?prev)
        )
    )

    (:action pick-up-patient
        :parameters (?r - robot-patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            ; check that the robot is not already loaded with another patient => here a robot can carry only one patient at a time ; CHECK
            ; (can be also done with a predicate ad hot as "can-carry-patient")
            (not (exists
                    (?p2 - patient)
                    (robot-has-patient ?r ?p2)))

            ; check that the patient is not already loaded with a robot ; CHECK
            (not (exists
                    (?r2 - robot-patient)
                    (robot-has-patient ?r2 ?p)))
        )
        :effect (and
            (robot-has-patient ?r ?p)
        )
    )

    (:action move-robot-patient
        :parameters (?r - robot-patient ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            ; Move patient if robot is carrying one
            (forall
                (?p - patient)
                (when
                    (robot-has-patient ?r ?p)
                    (and
                        (at ?p ?to)
                        (not (at ?p ?from))
                    )
                )
            )
        )
    )

    (:action deliver-patient
        :parameters (?r - robot-patient ?p - patient ?u - medical-unit ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (at ?u ?l)
            (patient-needs-unit ?p ?u)
            (robot-has-patient ?r ?p)
        )
        :effect (and
            (patient-at-unit ?p ?u)
            (not (patient-needs-unit ?p ?u))
            (not (robot-has-patient ?r ?p))
        )
    )
)