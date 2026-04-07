;;; ============================================================================
;;; SelByLine.lsp
;;;
;;; Selects all objects in the drawing whose lineweight matches that of a
;;; user-picked reference object (resolving BYLAYER through the layer table).
;;;
;;; Command:    SelByLine
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByLine (/ selObj entData lineweight layerName layerWeight filterList)
  (setq selObj (car (entsel "\nSelect an object to match lineweight: ")))
  (if selObj
    (progn
      (setq entData (entget selObj))
      ;; DXF 370 = lineweight. Value -1 means BYLAYER, so we must resolve
      ;; the effective lineweight from the object's layer definition.
      (setq lineweight (cdr (assoc 370 entData)))
      (if (= lineweight -1)
        (progn
          (setq layerName   (cdr (assoc 8 entData)))           ; DXF 8 = layer name
          (setq layerWeight (cdr (assoc 370 (tblsearch "layer" layerName))))
          (setq filterList  (list (cons 370 layerWeight)))
        )
        (setq filterList (list (cons 370 lineweight)))
      )
      ;; ssget "X" performs a database-wide filtered selection.
      (sssetfirst nil (ssget "X" filterList))
      (princ (strcat "\nAll objects with lineweight "
                     (if (= lineweight -1)
                       (strcat "BYLAYER (" (rtos layerWeight) ")")
                       (rtos lineweight)
                     )
                     " have been selected."))
    )
    (princ "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: SelByLine. Type SelByLine at the command line.")
(princ)
