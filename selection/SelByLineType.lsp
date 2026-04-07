;;; ============================================================================
;;; SelByLineType.lsp
;;;
;;; Selects all objects in the drawing whose linetype matches that of a
;;; user-picked reference object (resolving BYLAYER through the layer table).
;;;
;;; Command:    SelByLineType
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByLineType (/ selObj entData linetypeName layerName layerLinetype filterList)
  (setq selObj (car (entsel "\nSelect an object to match linetype: ")))
  (if selObj
    (progn
      (setq entData (entget selObj))
      ;; DXF 6 = linetype name. Absent or "BYLAYER" means we must look up
      ;; the layer's linetype via the layer symbol table.
      (setq linetypeName (cdr (assoc 6 entData)))
      (if (or (null linetypeName) (equal linetypeName "BYLAYER"))
        (progn
          (setq layerName     (cdr (assoc 8 entData)))          ; DXF 8 = layer name
          (setq layerLinetype (cdr (assoc 6 (tblsearch "layer" layerName))))
          (setq filterList    (list (cons 6 layerLinetype)))
        )
        (setq filterList (list (cons 6 linetypeName)))
      )
      (sssetfirst nil (ssget "X" filterList))
      (princ (strcat "\nAll objects with linetype '"
                     (if linetypeName linetypeName "BYLAYER")
                     "' have been selected."))
    )
    (princ "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: SelByLineType. Type SelByLineType at the command line.")
(princ)
