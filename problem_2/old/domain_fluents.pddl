(define (domain health-care-2)
    (:requirements :strips :typing :negative-preconditions :numeric-fluents)

    (:types
        medical-unit box content robot patient - locatable
        robot-box robot-patient - robot
        location - object
    )

    (:functions
        (carrier-capacity ?cr - carrier) ; max capacity of the carrier
        (carrier-load ?cr - carrier) ; current load of the carrier
    )

    (:predicates
        ; location predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
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
        ; robot-patient predicates
        (robot-has-patient ?r - robot-patient ?p - patient)
    )

    (:action load-box-carrier
        :parameters (?r - robot-box ?b - box ?c - carrier ?l - location)
        :precondition (and
            ; box and robot are at the same location
            (at ?r ?l)
            (at ?b ?l)
            ; robot has that carrier
            (robot-has-carrier ?r ?c)
            ; carrier can be loaded with that box
            (< (carrier-load ?c) (carrier-capacity ?c))
            ; the box is not already loaded in another ; CHECK
            (not (exists
                    (?c2 - carrier)
                    (box-in-carrier ?b ?c2)))
        )
        :effect (and
            (box-in-carrier ?b ?c)
            (increase (carrier-load ?c) 1)
        )
    )

    (:action fill-box
        :parameters (?r - robot-box ?cr - carrier ?b - box ?c - content ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            (robot-has-carrier ?r ?cr)
            (box-in-carrier ?b ?cr)
            (empty ?b)
            (content-available ?c ?l)
        )
        :effect (and
            (not (empty ?b))
            (box-has-content ?b ?c)
            (not (content-available ?c ?l)) ; basically this means that the content is no longer available at the warehouse 
        )
    )

    (:action move-robot-box
        :parameters (?r - robot-box ?c - carrier ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (connected ?from ?to)
            (robot-has-carrier ?r ?c)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
            ; Move box if robot is carrying in its carrier
            (forall
                (?b - box)
                (when
                    (box-in-carrier ?b ?c)
                    (and
                        (at ?b ?to)
                        (not (at ?b ?from))
                    )
                )
            )
        )
    )

    (:action deliver-content
        :parameters (?r - robot-box ?cr - carrier ?b - box ?u - medical-unit ?c - content ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?u ?l)
            (robot-has-carrier ?r ?cr)
            (box-in-carrier ?b ?cr)
            (box-has-content ?b ?c)
            (unit-needs-content ?u ?c) ; the predicate "unit-needs-content" is an extra check to avoid delivering content to a unit that does not need it, so to avoid extra moves
        )
        :effect (and
            (unit-has-content ?u ?c)
            (not (unit-needs-content ?u ?c))
            (not (box-has-content ?b ?c))
            (not (box-in-carrier ?b ?cr)) ; the box is no longer in the carrier
            (empty ?b)
            (at ?b ?l) ; box is empty and at the location (can be reused)
            ; update carrier load
            (decrease (carrier-load ?cr) 1)
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