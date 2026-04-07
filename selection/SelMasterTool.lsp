;;; ============================================================================
;;; SelMasterTool.lsp
;;;
;;; Interactive selection refinement and batch action tool: filters an initial
;;; selection set by layer, color, or block name, then applies one of several
;;; common operations (isolate, freeze, join, draw order, move, copy, align).
;;;
;;; Command:    SelMasterTool
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelMasterTool (/ selObjs action entData layerNames colorList
                          byLayerColors cnt layerName colorIndex blockNames
                          refObj)
  ;; Phase 1: initial selection
  (setq selObjs (ssget))

  (if selObjs
    (progn
      ;; Phase 2: prompt user for a refinement strategy
      (initget "1 2 3 4 5")
      (setq action (getkword "\nPress [1] Select by layers, [2] Similar objects, [3] By colors, [4] Proceed without changes, [5] Select same block instances: "))

      (cond
        ;; Option 1: expand selection to everything on the same layers
        ((= action "1")
          (setq layerNames '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            (setq layerName (cdr (assoc 8 entData))) ; 8 = layer name (DXF)
            (if (and layerName (not (member layerName layerNames)))
              (setq layerNames (cons layerName layerNames))
            )
            (setq cnt (1+ cnt))
          )
          ;; Comma-joined layer list is the DXF wildcard form accepted by ssget
          (setq selObjs (ssget "_X" (list (cons 8 (apply 'strcat (mapcar '(lambda (x) (strcat x ",")) layerNames))))))
          (princ "\nObjects on the same layers selected.")
        )

        ;; Option 2: similar objects (not yet implemented)
        ((= action "2")
          (princ "\nThis feature is not yet implemented.")
        )

        ;; Option 3: expand selection to everything sharing the same colors
        ((= action "3")
          (setq colorList '())
          (setq byLayerColors '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            (setq colorIndex (cdr (assoc 62 entData))) ; 62 = indexed color (DXF)
            (if colorIndex
              (if (not (member colorIndex colorList))
                (setq colorList (cons colorIndex colorList))
              )
              ;; No direct color override, fall back to the layer's color
              (let ((layerData (tblsearch "layer" (cdr (assoc 8 entData)))))
                (setq colorIndex (cdr (assoc 62 layerData)))
                (if (and colorIndex (not (member colorIndex byLayerColors)))
                  (setq byLayerColors (cons colorIndex byLayerColors))
                )
              )
            )
            (setq cnt (1+ cnt))
          )
          (setq selObjs (ssget "_X" (mapcar '(lambda (col) (cons 62 col)) (append colorList byLayerColors))))
          (princ "\nSelected objects by color.")
        )

        ;; Option 4: keep the original selection untouched
        ((= action "4")
          (princ "\nProceeding with the original selection.")
        )

        ;; Option 5: expand to every instance of the picked blocks
        ((= action "5")
          (setq blockNames '())
          (setq cnt 0)
          (repeat (sslength selObjs)
            (setq entData (entget (ssname selObjs cnt)))
            (if (eq (cdr (assoc 0 entData)) "INSERT") ; 0 = entity type
              (let ((blockName (cdr (assoc 2 entData)))) ; 2 = block name
                (if (and blockName (not (member blockName blockNames)))
                  (setq blockNames (cons blockName blockNames))
                )
              )
            )
            (setq cnt (1+ cnt))
          )
          (if blockNames
            (progn
              (setq selObjs (ssget "_X" (list (cons 0 "INSERT") (cons 2 (apply 'strcat (mapcar '(lambda (x) (strcat x ",")) blockNames))))))
              (princ "\nAll instances of the same block(s) selected.")
            )
            (princ "\nNo blocks were identified in the initial selection.")
          )
        )

        (T (princ "\nInvalid action."))
      )

      ;; Phase 3: act on the refined selection
      (if selObjs
        (progn
          (initget "Q W E R T 1 2 3 4 5 6")
          (setq action (getkword "\n[Q] Isolate, [W] Freeze, [E] Join, [R] Send Back, [T] Under Object, [1] Move, [2] Copy, [3] Align, [4] Bring Front, [5] Send Above, [6] Leave Selection: "))
          (cond
            ((= action "Q") ; isolate
              (command "ISOLATEOBJECTS" selObjs)
              (princ "\nObjects isolated.")
            )
            ((= action "W") ; freeze collected layers
              (foreach layer layerNames
                (command "LAYER" "FREEZE" layer "")
              )
              (princ "\nLayers frozen.")
            )
            ((= action "E") ; join
              (command "JOIN" selObjs "")
              (princ "\nObjects joined.")
            )
            ((= action "R") ; draw order: back
              (command "DRAWORDER" selObjs "" "Back")
              (princ "\nObjects sent back.")
            )
            ((= action "T") ; draw order: below a reference
              (princ "\nSelect reference object: ")
              (setq refObj (car (entsel)))
              (if refObj
                (command "DRAWORDER" selObjs "" "Below" refObj)
                (princ "\nNo reference object selected.")
              )
            )
            ((= action "1") ; move
              (princ "\nMove the objects.")
              (command "MOVE" selObjs "")
              (princ "\nObjects moved.")
            )
            ((= action "2") ; copy
              (princ "\nCopy the objects.")
              (command "COPY" selObjs "")
              (princ "\nObjects copied.")
            )
            ((= action "3") ; align
              (command "ALIGN" selObjs "")
              (princ "\nObjects aligned.")
            )
            ((= action "4") ; draw order: front
              (command "DRAWORDER" selObjs "" "Front")
              (princ "\nObjects brought to front.")
            )
            ((= action "5") ; draw order: above a reference
              (princ "\nSelect reference object: ")
              (setq refObj (car (entsel)))
              (if refObj
                (command "DRAWORDER" selObjs "" "Above" refObj)
                (princ "\nNo reference object selected.")
              )
            )
            ((= action "6") ; keep selection, no-op
              (princ "\nLeaving selection as it is.")
            )
            (T (princ "\nInvalid action."))
          )
        )
        (princ "\nNo objects selected for further actions.")
      )
    )
    (princ "\nNo objects selected.")
  )
  (princ)
)

(princ "\nLoaded: SelMasterTool. Type SelMasterTool at the command line.")
(princ)
