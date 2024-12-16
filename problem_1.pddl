(define (problem problem_1) (:domain healthcare)
(:objects 
)

(:init
    ; - Initially all boxes are located at a single location that we may call the central_warehouse.
    ; - All the contents to load in the boxes are initially located at the central_warehouse.
    ; - There are no medical unit at the central_warehouse.
    ; - A single robotic agent allowed to carry boxes is located at the central_warehouse to deliver boxes.
    ; - A single robotic agent allowed to accompany patients is initially located at the entrance. There are no particular restrictions on the number of boxes available, and constraints on reusing boxes! These are design modeling choices left unspecified and that each student shall consider and specify in her/his solution. There are no restrictions on the number of patients to be accompanied

)

(:goal (and
    ; - certain medical units have certain supplies;
    ; - some medical units might not need supply;
    ; - some medical units might need several supplies;
    ; - some patients need to reach some medical unit.
    
    ; This means that the robotic agent has to deliver to needing medical unit some or all of the boxes and content initially located at the central_warehouse, and leave the content by removing the content from the box (removing a content from the box causes the medical unit at the same location to have the unloaded content).
))

;  Remarks medical unit don’t care exactly which content they get, so the goal should not be (for example) that MedicalUnit1 has scissor1, and scalpel5, merely that MedicalUnit1 has a scissor and a scalpel.

)
