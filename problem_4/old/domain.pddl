(define (domain health-care-temporal)
    (:requirements :strips :typing :fluents :durative-actions)

    (:types
        medical-unit box content robot patient - locatable
        robot-box robot-patient - robot
        location 
        carrier
    )

    (:predicates
        (at ?o - locatable ?l - location)
        (connected ?l1 - location ?l2 - location)
        (is-central_warehouse ?l - location)
        (box-empty ?b - box)
        (box-has-content ?b - box ?c - content)
        (content-available ?c - content ?l - location)
        (unit-needs-content ?u - medical-unit ?c - content)
        (unit-has-content ?u - medical-unit ?c - content)
        (patient-needs-unit ?p - patient ?u - medical-unit)
        (patient-at-unit ?p - patient ?u - medical-unit)
        (robot-has-carrier ?r - robot ?cr - carrier)
        (box-in-carrier ?b - box ?cr - carrier)
        (robot-has-patient ?r - robot-patient ?p - patient)
        (robot-available ?r - robot)
        (robot-working ?r - robot)
        (box-available ?b - box)
    )

    (:functions
        (carrier-capacity ?cr - carrier)    ; Maximum capacity
        (carrier-load ?cr - carrier)        ; Current load
    )

    (:durative-action load-box-carrier
        :parameters (?r - robot-box ?b - box ?c - carrier ?l - location)
        :duration (= ?duration 2)
        :condition (and 
            (at start (and
                (at ?r ?l)
                (at ?b ?l)
                (robot-has-carrier ?r ?c)
                (robot-available ?r)
                (box-available ?b)
                (<= (+ (carrier-load ?c) 1) (carrier-capacity ?c))
            ))
            (over all (and
                (at ?r ?l)
                (at ?b ?l)
                (robot-working ?r)
            ))
        )
        :effect (and 
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
                (not (box-available ?b))
                (increase (carrier-load ?c) 1)
            ))
            (at end (and
                (box-in-carrier ?b ?c)
                (not (at ?b ?l))
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action fill-box
        :parameters (?r - robot-box ?cr - carrier ?b - box ?c - content ?l - location)
        :duration (= ?duration 10)
        :condition (and 
            (at start (and
                (at ?r ?l)
                (at ?b ?l)
                (robot-has-carrier ?r ?cr)
                (box-empty ?b)
                (content-available ?c ?l)
                (box-available ?b)
                (robot-available ?r)
            ))
            (over all (and
                (at ?r ?l)
                (at ?b ?l)
                (robot-working ?r)
                (content-available ?c ?l)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
            ))
            (at end (and
                (not (box-empty ?b))
                (box-has-content ?b ?c)
                (not (content-available ?c ?l))
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action move-robot-box
        :parameters (?r - robot-box ?c - carrier ?from - location ?to - location)
        :duration (= ?duration 15)
        :condition (and
            (at start (and
                (at ?r ?from)
                (connected ?from ?to)
                (robot-has-carrier ?r ?c)
                (robot-available ?r)
            ))
            (over all (and
                (robot-working ?r)
                (robot-has-carrier ?r ?c)
                (connected ?from ?to)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
                (not (at ?r ?from))
            ))
            (at end (and
                (at ?r ?to)
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action deliver-content
        :parameters (?r - robot-box ?cr - carrier ?b - box ?u - medical-unit ?c - content ?l - location)
        :duration (= ?duration 2)
        :condition (and
            (at start (and
                (at ?r ?l)
                (at ?u ?l)
                (robot-has-carrier ?r ?cr)
                (box-in-carrier ?b ?cr)
                (box-has-content ?b ?c)
                (unit-needs-content ?u ?c)
                (robot-available ?r)
                (> (carrier-load ?cr) 0)
            ))
            (over all (and
                (at ?r ?l)
                (at ?u ?l)
                (robot-working ?r)
                (box-has-content ?b ?c)
                (box-in-carrier ?b ?cr)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
            ))
            (at end (and
                (unit-has-content ?u ?c)
                (not (unit-needs-content ?u ?c))
                (not (box-has-content ?b ?c))
                (not (box-in-carrier ?b ?cr))
                (box-empty ?b)
                (box-available ?b)
                (at ?b ?l)
                (decrease (carrier-load ?cr) 1)
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action pick-up-patient
        :parameters (?r - robot-patient ?p - patient ?l - location)
        :duration (= ?duration 3)
        :condition (and
            (at start (and
                (at ?r ?l)
                (at ?p ?l)
                (robot-available ?r)
            ))
            (over all (and
                (at ?r ?l)
                (robot-working ?r)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
                (not (at ?p ?l))
            ))
            (at end (and
                (robot-has-patient ?r ?p)
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action move-robot-patient
        :parameters (?r - robot-patient ?p - patient ?from - location ?to - location)
        :duration (= ?duration 6)
        :condition (and
            (at start (and
                (at ?r ?from)
                (connected ?from ?to)
                (robot-has-patient ?r ?p)
                (robot-available ?r)
            ))
            (over all (and
                (robot-working ?r)
                (connected ?from ?to)
                (robot-has-patient ?r ?p)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
                (not (at ?r ?from))
            ))
            (at end (and
                (at ?r ?to)
                (robot-available ?r)
                (not (robot-working ?r))
            ))
        )
    )

    (:durative-action deliver-patient
        :parameters (?r - robot-patient ?p - patient ?u - medical-unit ?l - location)
        :duration (= ?duration 4)
        :condition (and
            (at start (and
                (at ?r ?l)
                (at ?u ?l)
                (patient-needs-unit ?p ?u)
                (robot-has-patient ?r ?p)
                (robot-available ?r)
            ))
            (over all (and
                (at ?r ?l)
                (at ?u ?l)
                (robot-working ?r)
                (robot-has-patient ?r ?p)
            ))
        )
        :effect (and
            (at start (and
                (not (robot-available ?r))
                (robot-working ?r)
            ))
            (at end (and
                (patient-at-unit ?p ?u)
                (not (patient-needs-unit ?p ?u))
                (not (robot-has-patient ?r ?p))
                (robot-available ?r)
                (not (robot-working ?r))
                (at ?p ?l)
            ))
        )
    )
)