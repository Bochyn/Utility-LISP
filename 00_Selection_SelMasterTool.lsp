(defun c:SelMasterTool (/ selObjs action entData layerNames colorList byLayerColors cnt layerName colorIndex blockNames)
  ;; Phase 1: Selection of objects
  (setq selObjs (ssget))
  
  (if selObjs
    (progn
      ;; Phase 2: Prompt user for action
      (initget "1 2 3 4 5")
      (setq action (getkword "\nPress [1] Select by layers, [2] Similar objects, [3] By colors, [4] Proceed without changes, [5] Select same block instances: "))

      ;; Process selection based on user choice
      (cond
        ;; Option 1: Select by layers
        ((= action "1")
          ;; Identify layers of selected objects
          (setq layerNames '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            (setq layerName (cdr (assoc 8 entData))) ;; Extract layer name
            (if (and layerName (not (member layerName layerNames)))
              (setq layerNames (cons layerName layerNames))
            )
            (setq cnt (1+ cnt))
          )
          ;; Select objects on the identified layers
          (setq selObjs (ssget "_X" (list (cons 8 (apply 'strcat (mapcar '(lambda (x) (strcat x ",")) layerNames))))))
          (princ "\nObjects on the same layers selected.")
        )
        ;; Option 2: Select similar objects (placeholder for future implementation)
        ((= action "2")
          (princ "\nThis feature is not yet implemented.")
        )
        ;; Option 3: Select by colors
        ((= action "3")
          ;; Identify colors of selected objects
          (setq colorList '())
          (setq byLayerColors '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            ;; Check for direct color assignment
            (setq colorIndex (cdr (assoc 62 entData)))
            (if colorIndex
              (if (not (member colorIndex colorList))
                (setq colorList (cons colorIndex colorList))
              )
              ;; If no direct color, check ByLayer color
              (let ((layerData (tblsearch "layer" (cdr (assoc 8 entData)))))
                (setq colorIndex (cdr (assoc 62 layerData)))
                (if (and colorIndex (not (member colorIndex byLayerColors)))
                  (setq byLayerColors (cons colorIndex byLayerColors))
                )
              )
            )
            (setq cnt (1+ cnt))
          )
          ;; Select objects based on identified colors
          (setq selObjs (ssget "_X" (mapcar '(lambda (col) (cons 62 col)) (append colorList byLayerColors))))
          (princ "\nSelected objects by color.")
        )
        ;; Option 4: Proceed without changes
        ((= action "4")
          (princ "\nProceeding with the original selection.")
        )
        ;; Option 5: Select all instances of the same block
        ((= action "5")
          ;; Identify block names from the selected objects
          (setq blockNames '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            (if (eq (cdr (assoc 0 entData)) "INSERT") ;; Check if the entity is a block reference
              (let ((blockName (cdr (assoc 2 entData)))) ;; Get the block name
                (if (and blockName (not (member blockName blockNames)))
                  (setq blockNames (cons blockName blockNames))
                )
              )
            )
            (setq cnt (1+ cnt))
          )
          ;; Select all instances of the identified block(s)
          (if blockNames
            (progn
              (setq selObjs (ssget "_X" (list (cons 0 "INSERT") (cons 2 (apply 'strcat (mapcar '(lambda (x) (strcat x ",")) blockNames))))))
              (princ "\nAll instances of the same block(s) selected.")
            )
            (princ "\nNo blocks were identified in the initial selection.")
          )
        )
        (T (princ "\nInvalid action.")) ;; Fallback for unexpected input
      )
      
      ;; Phase 3: Perform actions on the selection
      (if selObjs
        (progn
          (initget "Q W E R T 1 2 3 4 5 6")
          (setq action (getkword "\n[Q] Isolate, [W] Freeze, [E] Join, [R] Send Back, [T] Under Object, [1] Move, [2] Copy, [3] Align, [4] Bring Front, [5] Send Above, [6] Leave Selection: "))
          (cond
            ((= action "Q") ;; Isolate objects
              (command "ISOLATEOBJECTS" selObjs)
              (princ "\nObjects isolated.")
            )
            ((= action "W") ;; Freeze layer
              ;; Freeze layers of selected objects
              (foreach layer layerNames
                (command "LAYER" "FREEZE" layer "")
              )
              (princ "\nLayers frozen.")
            )
            ((= action "E") ;; Join command
              (command "JOIN" selObjs "")
              (princ "\nObjects joined.")
            )
            ((= action "R") ;; Send back
              (command "DRAWORDER" selObjs "" "Back")
              (princ "\nObjects sent back.")
            )
            ((= action "T") ;; Send under object
              (princ "\nSelect reference object: ")
              (setq refObj (car (entsel)))
              (if refObj
                (command "DRAWORDER" selObjs "" "Below" refObj)
                (princ "\nNo reference object selected.")
              )
            )
            ((= action "1") ;; Move objects
              (princ "\nMove the objects.")
              (command "MOVE" selObjs "")
              (princ "\nObjects moved.")
            )
            ((= action "2") ;; Copy objects
              (princ "\nCopy the objects.")
              (command "COPY" selObjs "")
              (princ "\nObjects copied.")
            )
            ((= action "3") ;; Align objects
              (command "ALIGN" selObjs "")
              (princ "\nObjects aligned.")
            )
            ((= action "4") ;; Bring to front
              (command "DRAWORDER" selObjs "" "Front")
              (princ "\nObjects brought to front.")
            )
            ((= action "5") ;; Send above
              (princ "\nSelect reference object: ")
              (setq refObj (car (entsel)))
              (if refObj
                (command "DRAWORDER" selObjs "" "Above" refObj)
                (princ "\nNo reference object selected.")
              )
            )
            ((= action "6") ;; Leave selection as it is
              (princ "\nLeaving selection as it is.")
            )
            (T (princ "\nInvalid action.")) ;; Fallback
          )
        )
        (princ "\nNo objects selected for further actions.")
      )
    )
    (princ "\nNo objects selected.") ;; If nothing was selected initially
  )
  (princ) ;; Graceful end
)
