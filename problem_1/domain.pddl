(define (domain healthcare)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        robot unit box content patient - locatable
        location - object
        robot-patient robot-delivery - robot ; robot-patient: accompanies patients, robot-delivery: carries boxes
        location - object
    )
    (:predicates
        ;; Location predicates
        (connected ?l1 - location ?l2 - location) ; "roadmap" with specific connections: robotic agents can move only between connected locations
        (at ?o - locatable ?l - location) ; object o is at location l

        ;; Box predicates
        (empty ?b - box) ; box b is empty
        (box-has-content ?b - box ?c - content) ; box b has content c
        (loaded ?r - robot-delivery ?b - box) ; robot r is loaded with box b

        ;; Unit predicates
        (unit-has-content ?u - unit ?c - content) ; unit u has content c

        ;; Patient predicates
        (is-accompanying ?r - robot-patient ?p - patient) ; robot r accompanies patient p
        (patient-at-unit ?p - patient ?u - unit) ; patient p is at unit u
        (need-accompaniment ?p - patient) ; patient p needs to be accompanied to some unit
            ; this assume that some patients need accompaniment to some unit
            ; and there can be patients that do not need accompaniment (not modeled here)
    )

    ;; Robot actions:

    ;; Move to another location
    (:action move
        :parameters (?r - robot ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
        )
        :effect (and
            (at ?r ?l2)
            (not (at ?r ?l1))
            ; robot-deliver: if the robotic agent is loaded with a box, then also the box moves with the agent itself
            (forall
                (?b - box)
                (when
                    (loaded ?r ?b)
                    (and
                        (at ?b ?l2)
                        (not (at ?b ?l1))
                    )
                )
            )
            ; robot-patient: if the robotic agent is accompanying a patient, then also the patient moves with the agent itself
            (forall
                (?p - patient)
                (when
                    (is-accompanying ?r ?p)
                    (and
                        (at ?p ?l2)
                        (not (at ?p ?l1))
                    )
                )
            )
        )
    )

    ;; Robot-delivery actions:

    ;; Pick up a single box and load it on the robotic agent, if it is at the same location as the box;
    (:action pickup
        :parameters (?r - robot-delivery ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)

            ; check that the box is not already loaded in other robot
            (not (exists
                    (?r2 - robot-delivery)
                    (loaded ?r2 ?b)))

            ; check that the robot is not already loaded with another box
            (not (exists
                    (?b2 - box)
                    (loaded ?r ?b2)))
        )
        :effect (and
            (loaded ?r ?b)
            (not (at ?b ?l))
        )
    )

    ;; Fill a box with a content, if the box is empty and the content to add in the box, the box and the robotic agent are at the same location;
    (:action fill
        :parameters (?r - robot-delivery ?b - box ?c - content ?l - location)
        :precondition (and
            (empty ?b)
            (at ?r ?l)
            (at ?b ?l)
        )
        :effect (and
            (box-has-content ?b ?c)
            (not (empty ?b))
        )
    )

    ;; Deliver a box to a specific medical unit who is at the same location. So empty a box by leaving the content to the current location and given medical unit, causing the medical unit to then have the content
    (:action deliver
        :parameters (?r - robot-delivery ?b - box ?c - content ?u - unit ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?u ?l)
            (loaded ?r ?b)
            (box-has-content ?b ?c)
        )
        :effect (and
            (not (loaded ?r ?b))
            (at ?b ?l)
            (empty ?b)
            (not (box-has-content ?b ?c)) ; box does not have content anymore
            (unit-has-content ?u ?c)
        )

    )

    ;; Robot-patient actions:

    ;; There are patients that need to be accompanied to the desired medical unit. The robotic agents can accompany patients to the desired unit. They can accompany only one patient at a time. 

    (:action carry-patient
        ; The robotic agent carries the patient to the desired medical unit.
        ; This action is used to activate the accompaniment of the patient by the robotic agent.
        :parameters (?r - robot-patient ?p - patient ?l1 - location)
        :precondition (and
            (at ?r ?l1)
            (at ?p ?l1)
            (need-accompaniment ?p) ; the patient needs accompaniment

            ; check that the robot is not already accompanying another patient
            (not (exists
                    (?p2 - patient)
                    (is-accompanying ?r ?p2)))
            ; check that the patient is not already accompanied by another robot
            (not (exists
                    (?r2 - robot-patient)
                    (is-accompanying ?r2 ?p)))
        )
        :effect (and 
            (is-accompanying ?r ?p) ; the robotic agent is accompanying the patient
        )
    )

    (:action patient-arrive-at-unit
        ; The robotic agent has accompanied the patient to the medical unit.
        ; Note that the movement of the patient is not modeled here, but trough the move action of the robot.
        ; Note that this action does not model the accompaniment of the patient ONLY to the desired unit
        ; but for each unit the patient reach with the accompaniment of the robot.
        ; The goal will be to reach the desired unit.
        :parameters (?r - robot-patient ?p - patient ?u - unit ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?p ?l)
            (at ?u ?l)
            (is-accompanying ?r ?p)
            (not (patient-at-unit ?p ?u)) ; the patient is not already at the desired medical unit 
        )
        :effect (and 
            (not (is-accompanying ?r ?p)) ; the robotic agent is not accompanying the patient anymore
            (patient-at-unit ?p ?u) ; the patient is at the desired medical unit
        )
    )
    
)