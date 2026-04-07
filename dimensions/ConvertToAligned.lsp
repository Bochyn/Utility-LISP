;;; ============================================================================
;;; ConvertToAligned.lsp
;;;
;;; Converts selected non-aligned dimensions into aligned dimensions in place.
;;;
;;; Command:    ConvertToAligned
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:ConvertToAligned (/ ss i ent entData dimType dimStyle pt1 pt2 dimTextPos)
  ;; Prompt user to select dimensions
  (setq ss (ssget '((0 . "DIMENSION"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq entData (entget ent))
        (setq dimType (cdr (assoc 0 entData)))      ; dimension type
        (if (not (equal dimType "DIMENSION"))       ; ensure it's a dimension entity
          (princ "\nSkipping non-dimension entity.")
          (progn
            (setq dimStyle    (cdr (assoc 3 entData)))   ; dimension style
            (setq pt1         (cdr (assoc 13 entData)))  ; first definition point
            (setq pt2         (cdr (assoc 14 entData)))  ; second definition point
            (setq dimTextPos  (cdr (assoc 11 entData)))  ; dimension text position
            ;; If the dimension is not already aligned, replace it
            (if (not (wcmatch (cdr (assoc 100 entData)) "*AcDbAlignedDimension*"))
              (progn
                (command "._DIMALIGNED" pt1 pt2 dimTextPos)  ; create aligned dimension
                (command "_erase" ent "")                    ; delete original dimension
              )
            )
          )
        )
        (setq i (1+ i))
      )
      (princ "\nAll non-aligned dimensions converted to aligned.")
    )
    (princ "\nNo dimensions selected.")
  )
  (princ)
)

(princ "\nLoaded: ConvertToAligned. Type ConvertToAligned at the command line.")
(princ)
