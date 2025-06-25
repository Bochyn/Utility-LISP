(defun c:ConvertToAligned ()
  (setq ss (ssget '((0 . "DIMENSION"))))  ;; Prompt user to select dimensions
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq entData (entget ent))
        (setq dimType (cdr (assoc 0 entData)))  ;; Get dimension type
        (if (not (equal dimType "DIMENSION"))  ;; Ensure it's a dimension entity
          (princ "\nSkipping non-dimension entity.")
          (progn
            (setq dimStyle (cdr (assoc 3 entData)))  ;; Get dimension style
            (setq pt1 (cdr (assoc 13 entData)))  ;; First definition point
            (setq pt2 (cdr (assoc 14 entData)))  ;; Second definition point
            (setq dimTextPos (cdr (assoc 11 entData)))  ;; Dimension text position
            ;; If the dimension is not already aligned, replace it
            (if (not (wcmatch (cdr (assoc 100 entData)) "*AcDbAlignedDimension*"))
              (progn
                (command "._DIMALIGNED" pt1 pt2 dimTextPos)  ;; Create aligned dimension
                (command "_erase" ent "")  ;; Delete original dimension
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
  (princ)  ;; Exit cleanly
)