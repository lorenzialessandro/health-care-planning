(define (domain health-care-basic)
    (:requirements :strips :typing :negative-preconditions)

    (:types
        medical-unit box content robot patient - locatable
        robot-box robot-patient - robot
        location - object
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
        ; robot-box predicates
        (robot-has-box ?r - robot-box ?b - box)
        ; robot-patient predicates
        (robot-has-patient ?r - robot-patient ?p - patient)
    )

    (:action pick-up-box
        :parameters (?r - robot-box ?b - box ?l - location)
        :precondition (and
            ; box and robot are at the same location
            (at ?r ?l)
            (at ?b ?l)
            ; if location is central_warehouse, then the box must be full
            (or
                (not (is-central_warehouse ?l)) 
                (not (empty ?b))
            )
            ; check that the robot is not already loaded with another box => here a robot can carry only one box at a time ; CHECK 
            ; (can be also done with a predicate ad hoc as "can-carry-box")
            (not (exists
                    (?b2 - box)
                    (robot-has-box ?r ?b2)))

            ; check that the box is not already loaded with a robot ; CHECK 
            (not (exists
                    (?r2 - robot-box)
                    (robot-has-box ?r2 ?b)))
        )
        :effect (and
            (robot-has-box ?r ?b)
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
    

    (:action fill-box
        :parameters (?r - robot-box ?b - box ?c - content ?l - location)
        :precondition (and
            ; box is empty
            (empty ?b)
            ; robot and box are at the same location
            (at ?r ?l)
            (at ?b ?l)
            ; content is available at the location
            (content-available ?c ?l)
        )
        :effect (and
            (not (empty ?b))
            (box-has-content ?b ?c)
            (not (content-available ?c ?l)) ; basically this means that the content is no longer available at the warehouse 
        )
    )

    (:action move-robot
        :parameters (?r - robot ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            ; Move box if robot is carrying one
            (forall
                (?b - box)
                (when
                    (robot-has-box ?r ?b)
                    (and
                        (at ?b ?to)
                        (not (at ?b ?from))
                    )
                )
            )
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

    (:action deliver-content
        :parameters (?r - robot-box ?b - box ?u - medical-unit ?c - content ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?u ?l)
            (robot-has-box ?r ?b)
            (box-has-content ?b ?c)   
            (unit-needs-content ?u ?c) ; the predicate "unit-needs-content" is an extra check to avoid delivering content to a unit that does not need it, so to avoid extra moves
            (not (empty ?b))
        )
        :effect (and
            (unit-has-content ?u ?c)
            (not (unit-needs-content ?u ?c))
            (not (box-has-content ?b ?c))
            (not (robot-has-box ?r ?b)) ; robot is not carrying the box anymore : robot is free to carry another box or to reuse the same box
            (empty ?b)
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