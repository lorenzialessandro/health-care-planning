(define (domain healthcare)
    (:requirements :strips :typing :negative-precondition)
    (:types
        robot unit box content patient - locatable 
        location - object
        robot_patient robot_delivery - robot ; type of robot: robot_patient: accompanies patients, robot_delivery: carries boxes
        location - object
    )
    (:predicates
        ; location predicates
        (connected ?l1 - location ?l2 - location) ; "roadmap" with specific connections: robotic agents can move only between connected locations
        (at ?o - locatable ?l - location) ; object o is at location l

        ; box predicates
        (empty ?b - box) ; box b is empty
        (box_has_content ?b - box ?c - content) ; box b has content c
        (loaded ?r - robot_delivery ?b - box) ; robot r is loaded with box b
        (available ?b - box) ; box b is available to be loaded ; TODO: check if this is necessary
        (available ?r - robot_delivery) ; robot r is available to be loaded ; TODO: check if this is necessary

        ; unit predicates
        (unit_has_content ?u - unit ?c - content) ; unit u has content c

        ; patient predicates
        (need_accompaniment ?p - patient ?u - unit) ; patient p needs accompaniment to unit u
        (accompanying ?p - patient) ; patient p is accompanied by a robot
        (can_accompany ?r - robot_patient) ; robot r can accompany a patient
    )

    ; robot actions:

    ; move to another location considering that if the robotic agent is loaded with a box, then also the box moves with the agent itself, and if the agent is not loaded with a box, then only the agent moves to the new location
    (:action move
        :parameters (?r - robot ?l1 - location ?l2 - location)
        :precondition (and
            (at ?r ?l1)
            (connected ?l1 ?l2)
        )
        :effect (and
            (at ?r ?l2)
            (not (at ?r ?l1))
            ; if the robot is loaded with a box, then also the box moves with the agent itself
            (forall (?b - box)
                (when (loaded ?r ?b)
                    (at ?b ?l2)
                    (not (at ?b ?l1))
                )
            )
        )
    )

    ; robot_delivery actions:

    ; pick up a single box and load it on the robotic agent, if it is at the same location as the box;
    (:action pickup
        :parameters (?r - robot_delivery ?b - box ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?b ?l)
            ; check that the box is not already loaded in other robot : check if b is available
            (available ?b) ; TODO: check if this is necessary
            ; check that the robot is not already loaded with another box
            (available ?r) ; TODO: check if this is necessary
        )
        :effect (and
            (loaded ?r ?b)
            (not (at ?b ?l))
            (not (available ?b))
            (not (available ?r))
        )    
    )

    ; fill a box with a content, if the box is empty and the content to add in the box, the box and the robotic agent are at the same location;
    (:action fill
        :parameters (?r - robot_delivery ?b - box ?c - content ?l - location)
        :precondition (and
            (empty ?b)
            (at ?r ?l)
            (at ?b ?l)
        )
        :effect (and 
            (box_has_content ?b ?c)
            (not (empty ?b))
        )
    )


    ; deliver a box to a specific medical unit who is at the same location. So empty a box by leaving the content to the current location and given medical unit, causing the medical unit to then have the content
    (:action deliver
        :parameters (?r - robot_delivery ?b - box ?c - content  ?u - unit ?l - location)
        :precondition (and
            (at ?r ?l)
            (at ?u ?l)
            (loaded ?r ?b)
            (box_has_content ?b ?c)
        )
        :effect (and 
            (not (loaded ?r ?b))
            (at ?b ?l)
            (empty ?b)
            (not (box_has_content ?b ?c)) ; TODO: check: box is empty so it does not have the content anymore
            (unit_has_content ?u ?c)
            (available ?b) ; box is available to be loaded again ; TODO: check if this is necessary
            (available ?r) ; robot is available to load another box ; TODO: check if this is necessary
        )
        
    )
    
    ; robot_patient actions:

    ; There are patients that need to be accompanied to the desired medical unit. The robotic agents can accompany patients to the desired unit.  they can accompany only one patient at a time. 
    (:action accompany
        :parameters (?r - robot_patient ?p - patient ?l1 - location ?l2 - location ?u - unit) 
        :precondition (and
            (need_accompaniment ?p ?u)
            (at ?r ?l1)
            (at ?p ?l1)
            (at ?u ?l2)
            (connected ?l1 ?l2)

            ; check that the robot is not already accompanying another patient
            (can_accompany ?r)
            
            ; check that the patient is not already accompanied by another robot
            (not (accompanying ?p))
            
        )
        :effect (and
            (at ?p ?l2)
            (not (at ?p ?l1))
            (at ?r ?l2)
            (not (at ?r ?l1))
            
            (accompanying ?p) ; patient is accompanied by the robot
            (not (can_accompany ?r)) ; robot cannot accompany another patient

        )
    )   

    (:action end-accompany
        :parameters (?r - robot_patient ?p - patient ?l - location ?u - unit)
        :precondition (and
            (accompanying ?p)
            (at ?r ?l)
            (at ?p ?l)
            (at ?u ?l)
        )
        :effect (and
            (not (need_accompaniment ?p ?u)) ; patient does not need accompaniment anymore
            (not (accompanying ?p)) ; patient is not accompanied by the robot anymore
            (can_accompany ?r) ; robot can accompany another patient now
        )
    ) 
)