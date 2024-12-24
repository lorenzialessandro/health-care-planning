(define (domain health-care-1)
    (:requirements :strips :typing :negative-preconditions :existential-preconditions :universal-preconditions)

    (:types
        medical-unit box content robot patient - locatable
        robot-box robot-patient - robot
        location - object
    )

    (:predicates
        ; location predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
        ; box predicates
        (empty ?b - box)
        (box-free ?b - box)
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
        (robot-can-carry ?r - robot-box)
        ; robot-patient predicates
        (robot-has-patient ?r - robot-patient ?p - patient)
        (robot-can-accompany ?r - robot-patient)
        (patient-free ?p - patient)
    )

    (:action pick-up-box
        :parameters (?r - robot-box ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)

            ; check that the robot is not already loaded with another box => here a robot can carry only one box at a time ; CHECK 
            (robot-can-carry ?r)

            ; check that the box is not already loaded with another robot ; CHECK 
            (box-free ?b)
        )
        :effect (and
            (robot-has-box ?r ?b)
            (not (robot-can-carry ?r))
            (not (box-free ?b))
        )
    )

    (:action pick-up-patient
        :parameters (?r - robot-patient ?p - patient ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)

            ; check that the robot is not already loaded with another patient => here a robot can carry only one patient at a time ; CHECK
            (robot-can-accompany ?r)
            
            ; check that the patient is not already loaded with a robot ; CHECK
            (patient-free ?p)
        )
        :effect (and
            (robot-has-patient ?r ?p)
            (not (robot-can-accompany ?r))
            (not (patient-free ?p))
        )
    )
    

    (:action fill-box
        :parameters (?r - robot-box ?b - box ?c - content ?l - location)
        :precondition (and
            (empty ?b)
            (at ?r ?l)
            (at ?b ?l)
            (content-available ?c ?l)
            (robot-has-box ?r ?b)
        )
        :effect (and
            (not (empty ?b))
            (box-has-content ?b ?c)
            (not (content-available ?c ?l)) ; basically this means that the content is no longer available at the warehouse 
        )
    )

    (:action move-robot-without-box 
        :parameters (?r - robot-box ?from ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (robot-can-carry ?r)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
        )
    )
    
    (:action move-robot-with-box
        :parameters (?r - robot-box ?b - box ?from ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (robot-has-box ?r ?b)
            (at ?b ?from)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            (at ?b ?to)
            (not (at ?b ?from))
        )
    )

    (:action move-robot-without-patient
        :parameters (?r - robot-patient ?from ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (robot-can-accompany ?r)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
        )
    )

    (:action move-robot-with-patient
        :parameters (?r - robot-patient ?p - patient ?from ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (robot-has-patient ?r ?p)
            (at ?p ?from)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            (at ?p ?to)
            (not (at ?p ?from))
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
        )
        :effect (and
            (unit-has-content ?u ?c)
            (not (unit-needs-content ?u ?c))
            (not (box-has-content ?b ?c))
            (not (robot-has-box ?r ?b)) ; robot is not carrying the box anymore : robot is free to carry another box or to reuse the same box
            ; box is empty and at the location (can be reused) : 
            (empty ?b)
            (at ?b ?l) 
            (robot-can-carry ?r)
            (box-free ?b)
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
            (robot-can-accompany ?r)
            (patient-free ?p)
        )

    )
)